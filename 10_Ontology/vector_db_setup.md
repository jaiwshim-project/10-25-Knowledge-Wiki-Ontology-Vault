# Vector DB Setup Guide
심재우 저서 Knowledge Base를 Vector DB로 구축하는 가이드

---

## 1. 개요

### 목적
- **의미 검색 (Semantic Search)** 구현
- **RAG (Retrieval-Augmented Generation)** 챗봇 구축
- **유사 지식 추천** 시스템 개발

### 추천 Vector DB
1. **Supabase pgvector** ⭐ (추천)
   - PostgreSQL 기반
   - 무료 티어 제공
   - Next.js 통합 용이

2. **Pinecone**
   - 전문 Vector DB
   - 높은 성능
   - 유료

3. **Weaviate**
   - 오픈소스
   - 온프레미스 가능

---

## 2. 데이터 구조

### Vector DB 스키마

```sql
-- Supabase pgvector 스키마
CREATE EXTENSION IF NOT EXISTS vector;

-- 1. Documents 테이블 (원본 문서)
CREATE TABLE documents (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  file_id TEXT NOT NULL,
  file_name TEXT NOT NULL,
  file_type TEXT NOT NULL,
  file_path TEXT NOT NULL,
  domain TEXT,
  main_topic TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  metadata JSONB
);

-- 2. Chunks 테이블 (청크 + 임베딩)
CREATE TABLE chunks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id UUID REFERENCES documents(id) ON DELETE CASCADE,
  chunk_id TEXT NOT NULL,
  content TEXT NOT NULL,
  embedding vector(1536),  -- OpenAI ada-002: 1536 dimensions
  chunk_type TEXT,
  source_location TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  metadata JSONB
);

-- 3. Knowledge Nodes 테이블 (노드 + 임베딩)
CREATE TABLE knowledge_nodes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  node_id TEXT UNIQUE NOT NULL,
  label TEXT NOT NULL,
  type TEXT NOT NULL,
  domain TEXT,
  description TEXT,
  embedding vector(1536),
  source_file TEXT,
  status TEXT DEFAULT 'active',
  tags TEXT[],
  created_at TIMESTAMP DEFAULT NOW(),
  metadata JSONB
);

-- 4. Markdown Notes 테이블 (Obsidian 노트 + 임베딩)
CREATE TABLE markdown_notes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  note_id TEXT UNIQUE NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  embedding vector(1536),
  note_type TEXT,
  folder TEXT,
  tags TEXT[],
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  metadata JSONB
);

-- 인덱스 생성 (성능 최적화)
CREATE INDEX ON chunks USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX ON knowledge_nodes USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX ON markdown_notes USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX ON chunks (document_id);
CREATE INDEX ON chunks (chunk_type);
CREATE INDEX ON knowledge_nodes (node_id);
CREATE INDEX ON knowledge_nodes (type);
CREATE INDEX ON knowledge_nodes (domain);
CREATE INDEX ON markdown_notes (note_type);
```

---

## 3. 임베딩 생성 스크립트

### Python 스크립트 (OpenAI)

```python
import os
import openai
import pandas as pd
import json
from supabase import create_client, Client

# 설정
SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)
openai.api_key = OPENAI_API_KEY

def get_embedding(text, model="text-embedding-ada-002"):
    """OpenAI API로 임베딩 생성"""
    text = text.replace("\n", " ")
    response = openai.Embedding.create(input=[text], model=model)
    return response['data'][0]['embedding']

# Step 1: Documents 임베딩
def embed_documents():
    """원본 문서 메타데이터 임베딩"""
    df = pd.read_csv('source_manifest.csv')
    
    for _, row in df.iterrows():
        # 문서 설명 생성
        text = f"{row['file_name']} - {row['main_topic']} ({row['domain']})"
        embedding = get_embedding(text)
        
        # Supabase에 저장
        data = {
            "file_id": row['file_id'],
            "file_name": row['file_name'],
            "file_type": row['file_type'],
            "file_path": row['path'],
            "domain": row['domain'],
            "main_topic": row['main_topic'],
            "metadata": {
                "size": row['size'],
                "status": row['status']
            }
        }
        supabase.table('documents').insert(data).execute()
        print(f"✅ {row['file_name']} embedded")

# Step 2: Knowledge Nodes 임베딩
def embed_knowledge_nodes():
    """온톨로지 노드 임베딩"""
    df = pd.read_csv('ontology_nodes.csv')
    
    for _, row in df.iterrows():
        # 노드 설명 텍스트 생성
        text = f"{row['label']}: {row['description']} (Type: {row['type']}, Domain: {row['domain']})"
        embedding = get_embedding(text)
        
        # Supabase에 저장
        data = {
            "node_id": row['node_id'],
            "label": row['label'],
            "type": row['type'],
            "domain": row['domain'],
            "description": row['description'],
            "embedding": embedding,
            "source_file": row['source_file'],
            "status": row['status'],
            "tags": row['tags'].split(';') if pd.notna(row['tags']) else [],
            "metadata": {
                "aliases": row['aliases'] if pd.notna(row['aliases']) else None
            }
        }
        supabase.table('knowledge_nodes').insert(data).execute()
        print(f"✅ {row['label']} embedded")

# Step 3: Markdown Notes 임베딩
def embed_markdown_notes():
    """Obsidian Markdown 노트 임베딩"""
    import glob
    
    md_files = glob.glob('**/*.md', recursive=True)
    
    for md_file in md_files:
        with open(md_file, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Frontmatter 추출
        import yaml
        if content.startswith('---'):
            parts = content.split('---', 2)
            frontmatter = yaml.safe_load(parts[1])
            body = parts[2].strip()
        else:
            frontmatter = {}
            body = content
        
        # 임베딩 생성 (제목 + 본문 요약)
        title = frontmatter.get('title', os.path.basename(md_file))
        text_for_embedding = f"{title}\n\n{body[:1000]}"  # 처음 1000자
        embedding = get_embedding(text_for_embedding)
        
        # Supabase에 저장
        data = {
            "note_id": os.path.basename(md_file).replace('.md', ''),
            "title": title,
            "content": body,
            "embedding": embedding,
            "note_type": frontmatter.get('type', 'unknown'),
            "folder": os.path.dirname(md_file),
            "tags": frontmatter.get('tags', []),
            "metadata": frontmatter
        }
        supabase.table('markdown_notes').insert(data).execute()
        print(f"✅ {title} embedded")

# 실행
if __name__ == "__main__":
    print("1. Embedding documents...")
    embed_documents()
    
    print("\n2. Embedding knowledge nodes...")
    embed_knowledge_nodes()
    
    print("\n3. Embedding markdown notes...")
    embed_markdown_notes()
    
    print("\n✅ All embeddings created!")
```

---

## 4. 검색 쿼리 예시

### 의미 검색 (Semantic Search)

```sql
-- 1. 유사 노드 검색
CREATE OR REPLACE FUNCTION search_similar_nodes(
  query_embedding vector(1536),
  match_threshold float DEFAULT 0.7,
  match_count int DEFAULT 10
)
RETURNS TABLE (
  node_id text,
  label text,
  description text,
  similarity float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    node_id,
    label,
    description,
    1 - (embedding <=> query_embedding) AS similarity
  FROM knowledge_nodes
  WHERE 1 - (embedding <=> query_embedding) > match_threshold
  ORDER BY similarity DESC
  LIMIT match_count;
$$;

-- 2. 유사 노트 검색
CREATE OR REPLACE FUNCTION search_similar_notes(
  query_embedding vector(1536),
  match_threshold float DEFAULT 0.7,
  match_count int DEFAULT 10
)
RETURNS TABLE (
  title text,
  content text,
  note_type text,
  similarity float
)
LANGUAGE sql STABLE
AS $$
  SELECT
    title,
    LEFT(content, 500) AS content,
    note_type,
    1 - (embedding <=> query_embedding) AS similarity
  FROM markdown_notes
  WHERE 1 - (embedding <=> query_embedding) > match_threshold
  ORDER BY similarity DESC
  LIMIT match_count;
$$;
```

### Python에서 검색

```python
def semantic_search(query: str, search_type: str = "nodes", limit: int = 5):
    """의미 기반 검색"""
    # 쿼리 임베딩 생성
    query_embedding = get_embedding(query)
    
    if search_type == "nodes":
        # 노드 검색
        result = supabase.rpc(
            'search_similar_nodes',
            {
                'query_embedding': query_embedding,
                'match_threshold': 0.7,
                'match_count': limit
            }
        ).execute()
    elif search_type == "notes":
        # 노트 검색
        result = supabase.rpc(
            'search_similar_notes',
            {
                'query_embedding': query_embedding,
                'match_threshold': 0.7,
                'match_count': limit
            }
        ).execute()
    
    return result.data

# 사용 예시
results = semantic_search("세일즈 프로세스", search_type="nodes", limit=5)
for r in results:
    print(f"{r['label']}: {r['similarity']:.3f}")
```

---

## 5. RAG 챗봇 구축

### Next.js API Route

```typescript
// app/api/chat/route.ts
import { createClient } from '@supabase/supabase-js'
import OpenAI from 'openai'

const supabase = createClient(
  process.env.SUPABASE_URL!,
  process.env.SUPABASE_KEY!
)
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY })

export async function POST(req: Request) {
  const { question } = await req.json()
  
  // 1. 질문 임베딩
  const embeddingResponse = await openai.embeddings.create({
    model: "text-embedding-ada-002",
    input: question,
  })
  const queryEmbedding = embeddingResponse.data[0].embedding
  
  // 2. 유사 지식 검색
  const { data: similarNodes } = await supabase.rpc('search_similar_nodes', {
    query_embedding: queryEmbedding,
    match_threshold: 0.7,
    match_count: 5
  })
  
  // 3. 컨텍스트 구성
  const context = similarNodes
    .map((node: any) => `${node.label}: ${node.description}`)
    .join('\n\n')
  
  // 4. GPT로 답변 생성
  const completion = await openai.chat.completions.create({
    model: "gpt-4",
    messages: [
      {
        role: "system",
        content: `당신은 심재우 저자의 GE 비즈니스 방법론 전문가입니다. 
다음 지식을 바탕으로 질문에 답변하세요:

${context}`
      },
      {
        role: "user",
        content: question
      }
    ],
    temperature: 0.7,
    max_tokens: 500
  })
  
  return Response.json({
    answer: completion.choices[0].message.content,
    sources: similarNodes
  })
}
```

---

## 6. 실행 가이드

### 단계별 실행

```bash
# 1. 환경 설정
cp .env.example .env
# SUPABASE_URL, SUPABASE_KEY, OPENAI_API_KEY 입력

# 2. 의존성 설치
pip install openai supabase pandas pyyaml

# 3. Supabase 테이블 생성
# Supabase Dashboard → SQL Editor → 위의 스키마 실행

# 4. 임베딩 생성
python embed_knowledge.py

# 5. 검색 테스트
python test_search.py

# 6. Next.js 앱 실행 (RAG 챗봇)
npm run dev
```

---

## 7. 예상 비용

### OpenAI Embeddings (ada-002)
- **가격**: $0.0001 / 1K tokens
- **예상 토큰**: 
  - 38 노드 × 평균 200 tokens = 7,600 tokens
  - 9 노트 × 평균 500 tokens = 4,500 tokens
  - **총**: ~12,000 tokens
- **비용**: **$0.0012** (약 1.5원)

### Supabase pgvector
- **무료 티어**: 500MB 데이터베이스
- **예상 사용량**: ~5MB
- **비용**: **무료**

### 총 예상 비용
- **초기 구축**: ~$0.01 (약 13원)
- **월 운영**: 검색 쿼리 비용만 (거의 무료)

---

## 8. 고급 기능

### Hybrid Search (Keyword + Semantic)

```sql
CREATE OR REPLACE FUNCTION hybrid_search(
  query_text text,
  query_embedding vector(1536),
  match_count int DEFAULT 10
)
RETURNS TABLE (
  node_id text,
  label text,
  description text,
  combined_score float
)
LANGUAGE sql STABLE
AS $$
  WITH semantic AS (
    SELECT
      node_id,
      label,
      description,
      1 - (embedding <=> query_embedding) AS similarity
    FROM knowledge_nodes
  ),
  keyword AS (
    SELECT
      node_id,
      label,
      description,
      ts_rank(to_tsvector('korean', description), plainto_tsquery('korean', query_text)) AS rank
    FROM knowledge_nodes
  )
  SELECT
    s.node_id,
    s.label,
    s.description,
    (s.similarity * 0.7 + k.rank * 0.3) AS combined_score
  FROM semantic s
  JOIN keyword k ON s.node_id = k.node_id
  ORDER BY combined_score DESC
  LIMIT match_count;
$$;
```

---

## 9. 체크리스트

- [ ] Supabase 프로젝트 생성
- [ ] pgvector extension 활성화
- [ ] 테이블 스키마 생성
- [ ] OpenAI API 키 발급
- [ ] 환경 변수 설정
- [ ] Python 스크립트 실행
- [ ] 임베딩 생성 완료 확인
- [ ] 검색 쿼리 테스트
- [ ] RAG 챗봇 구축
- [ ] 프론트엔드 통합

---

## 10. 참고 자료

- [Supabase pgvector 문서](https://supabase.com/docs/guides/database/extensions/pgvector)
- [OpenAI Embeddings API](https://platform.openai.com/docs/guides/embeddings)
- [LangChain Supabase Integration](https://python.langchain.com/docs/integrations/vectorstores/supabase)

---

**다음 단계**: `embed_knowledge.py` 스크립트를 실행하여 임베딩을 생성하세요!
