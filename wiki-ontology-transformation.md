# Wiki-Ontology Transformation

폴더 자료를 Obsidian Wiki와 온톨로지 지식DB로 전환하는 스킬

## When to use

다음 상황에서 이 스킬을 사용합니다:

- 특정 폴더를 Obsidian Wiki로 전환하고 싶을 때
- 많은 문서를 구조화된 Markdown 노트로 정리하고 싶을 때
- 파일 안의 개념, 문제, 해결책, 방법론, 사례, 전략을 추출하고 싶을 때
- 온톨로지 노드와 관계를 만들고 싶을 때
- 개인 또는 기업 문서를 지식 그래프로 만들고 싶을 때
- AI가 검색할 수 있는 지식 기반을 만들고 싶을 때
- 흩어진 PC 자료를 재사용 가능한 지식 자산으로 바꾸고 싶을 때

## What this skill does

이 스킬은 사용자가 지정한 폴더의 문서, 파일, 메모, 슬라이드, 스프레드시트, PDF, 이미지를 분석하여:

1. **Obsidian 호환 Markdown Wiki Vault** 생성
2. **온톨로지 기반 Knowledge DB** 구축
3. **AI 검색 및 재사용 가능한 지식 기반** 제공
4. **Knowledge Graph (노드·엣지·CSV·JSON)** 출력

```text
폴더 자료
→ 파일 스캔
→ 본문 추출
→ 지식 단위 분해
→ Obsidian Wiki
→ 온톨로지 지식 그래프
→ Knowledge DB
→ AI Agent 활용
```

## Instructions

당신은 **Wiki-Ontology Transformation Skill**을 실행하는 AI Agent입니다.

### 핵심 개념

폴더는 단순 저장 공간이 아닙니다. 폴더는 **아직 구조화되지 않은 숨은 지식 자산**입니다.

이 스킬은 흩어진 파일을 **연결된 지식 운영체제**로 전환합니다.

---

## Phase 1: 입력 수집 및 검증

### Step 1.1: 사용자 입력 확인

사용자에게 다음 정보를 요청합니다 (누락된 경우):

**필수 입력값:**
```yaml
input_folder: "원본 자료 폴더 경로"
output_folder: "결과 Vault 출력 폴더 경로"
project_name: "프로젝트 이름"
language: "ko"
```

**선택 입력값:**
```yaml
domain: "business / hospital_ai / education / manufacturing / sales / culture / startup / etc."
scan_mode: "recursive"
ontology_depth: "basic / standard / advanced"
include_images: true
include_tables: true
generate_graph_json: true
generate_review_queue: true
```

**입력 예시:**
```yaml
input_folder: "D:/Projects/MedVo"
output_folder: "D:/ObsidianVaults/MedVo_Knowledge"
project_name: "MedVo"
domain: "hospital_ai"
language: "ko"
scan_mode: "recursive"
ontology_depth: "standard"
```

### Step 1.2: 폴더 검증

- 입력 폴더 존재 여부 확인
- 접근 권한 확인
- 출력 폴더 생성 (존재하지 않는 경우)

---

## Phase 2: 파일 스캔 및 메타데이터 추출

### Step 2.1: 파일 스캔

다음 명령으로 모든 파일을 재귀적으로 스캔합니다:

```bash
find "{input_folder}" -type f ! -name ".*" ! -name "~*"
```

**지원 파일 형식:**
- PDF, DOCX, HWP, PPTX, XLSX
- TXT, MD, HTML, CSV, JSON
- PNG, JPG, JPEG, WEBP
- MP3, MP4 (녹취록/자막)

**제외 파일:**
- 임시 파일 (~*.tmp)
- 숨김 파일 (.*)
- 시스템 파일

### Step 2.2: 메타데이터 추출

각 파일에서 다음 메타데이터를 추출합니다:

```yaml
title:
source_file:
file_type:
file_path:
created_at:
modified_at:
author:
domain:
topic:
document_type:
version:
status:
importance:
confidentiality:
related_projects:
related_people:
related_companies:
tags:
```

### Step 2.3: source_manifest.csv 생성

```csv
file_id,file_name,file_type,path,size,created_at,modified_at,status
F001,MedVo_제안서.docx,DOCX,D:/Projects/MedVo,2.3MB,2026-05-20,2026-05-22,ready
F002,외국인환자유치전략.pptx,PPTX,D:/Projects/MedVo,8.1MB,2026-05-21,2026-05-23,ready
```

출력 위치: `{output_folder}/10_Ontology/source_manifest.csv`

---

## Phase 3: 본문 추출 및 청킹

### Step 3.1: 파일 유형별 본문 추출

**PDF:**
- Use Read tool for PDF files
- 페이지 단위 텍스트 추출

**DOCX:**
- 제목, 문단, 표 추출
- 구조 보존

**PPTX:**
- 슬라이드 제목, 본문, 도형 텍스트, 표, 발표자 노트 추출

**XLSX:**
- 시트명, 컬럼명, 표, 주요 지표 추출

**TXT, MD:**
- 문단과 구간 단위 추출
- Markdown 구조 유지

**HTML:**
- 제목, 본문, 링크, 헤딩 추출

**이미지:**
- 파일명, 경로, 크기 메타데이터 수집
- (필요 시 OCR - 향후 고도화)

### Step 3.2: 본문 청킹

추출된 본문을 의미 단위로 나눕니다.

**청킹 규칙:**
- 하나의 청크에는 하나의 핵심 의미만 담습니다
- 원본 위치를 유지합니다
- 표와 슬라이드의 맥락을 보존합니다
- 서로 관련 없는 내용을 합치지 않습니다

**청크 유형:**
```text
concept, definition, problem, cause, solution, function, process, methodology,
framework, case, customer_need, business_model, risk, strategy, KPI, checklist,
script, question, claim, evidence, insight, template, quote, data_point
```

**출력 형식:**
```json
{
  "file_id": "F001",
  "chunks": [
    {
      "chunk_id": "F001-C001",
      "source_location": "page 1",
      "title": "MedVo 개요",
      "text": "MedVo는 외국인 환자를 위한 AI 상담통역 플랫폼이다.",
      "type": "definition"
    }
  ]
}
```

---

## Phase 4: 지식 단위 분해 및 분류

### Step 4.1: 지식 단위 추출

청크에서 다음을 추출합니다:

- **개념 (Concept)**: 핵심 용어, 시스템, 플랫폼, 제품
- **문제 (Problem)**: 고객/시장 문제, 페인 포인트
- **해결책 (Solution)**: 문제에 대한 해결 방식
- **기능 (Function)**: 시스템이 제공하는 기능
- **프로세스 (Process)**: 단계별 절차
- **방법론 (Methodology)**: 프레임워크, 접근법
- **고객 (Customer)**: 타겟, 페르소나, 기업명
- **사람 (Person)**: 저자, 담당자, 관계자
- **KPI**: 측정 지표
- **리스크 (Risk)**: 잠재적 위험
- **산출물 (Output)**: 생성 가능한 결과물

**지식 단위 예시:**
```yaml
concept: MedVo
target: 외국인 환자
function:
  - 문의 수집
  - 다국어 AI 상담
  - 진료 전 문진
  - 상담실장 코칭
kpi:
  - 예약 전환율
parent_concept: 병원 외국인 환자 유치 AI 운영체제
```

### Step 4.2: 지식 단위 분류

각 지식 단위에 카테고리를 부여합니다:

```text
Project, Concept, Problem, Solution, Function, Process, Methodology, Framework,
Customer, Person, Company, Case, Document, Output, KPI, Risk, Market, Technology,
Template, Reference
```

---

## Phase 5: Obsidian Markdown 노트 생성

### Step 5.1: 출력 Vault 구조 생성

```text
{output_folder}/
  00_Index/
    Home.md
    Project_Index.md
    Concept_Index.md
    People_Index.md
    Company_Index.md
    Methodology_Index.md
    Document_Index.md
    Output_Index.md
    Ontology_Index.md
  01_Projects/
  02_Concepts/
  03_Methodologies/
  04_Customers/
  05_Documents/
  06_Cases/
  07_Templates/
  08_Outputs/
  09_References/
  10_Ontology/
  11_Review/
  99_Archive/
```

### Step 5.2: Markdown 노트 생성

**표준 노트 템플릿:**

```markdown
---
title: {{title}}
type: {{type}}
domain: {{domain}}
status: {{status}}
source_file: {{source_file}}
source_chunk: {{chunk_id}}
created: {{created_date}}
tags:
  - {{tag1}}
  - {{tag2}}
---

# {{title}}

## 1. 한 줄 정의
{{one_line_definition}}

## 2. 핵심 요약
{{summary}}

## 3. 주요 구성 요소
{{key_elements}}

## 4. 관련 문제
{{related_problems}}

## 5. 해결 방식
{{solutions}}

## 6. 활용 가능 산출물
{{possible_outputs}}

## 7. 연결 노트
{{internal_links}}

## 8. 원본 출처
- 파일명: {{source_file}}
- 위치: {{source_location}}
- 추출 단위: {{chunk_id}}

## 9. 검토 필요 사항
{{review_items}}
```

### Step 5.3: 내부 링크 생성

**링크 생성 기준:**
```text
프로젝트 ↔ 기능
프로젝트 ↔ 문제
프로젝트 ↔ 고객
문제 ↔ 해결책
해결책 ↔ 기능
방법론 ↔ 사례
고객 ↔ 제안서
KPI ↔ 프로세스
문서 ↔ 추출 개념
산출물 ↔ 원본 자료
```

**링크 예시:**
```text
[[MedVo]] → [[AI상담통역]]
[[MedVo]] → [[외국인 환자 유치]]
[[AI상담코칭]] → [[상담실장 교육]]
```

**링크 품질 규칙:**
- 관련성이 높은 개념만 연결합니다
- 과도한 링크 생성을 피합니다
- 넓은 개념은 허브 노트로 관리합니다
- 중복 노트는 링크 전에 병합합니다
- 동의어는 alias로 처리합니다

### Step 5.4: 인덱스 페이지 생성

**Home.md 템플릿:**

```markdown
# {{project_name}} Knowledge Vault

## 1. 프로젝트
{{project_links}}

## 2. 핵심 개념
{{concept_links}}

## 3. 고객 / 기업
{{customer_links}}

## 4. 방법론
{{methodology_links}}

## 5. 문서
{{document_links}}

## 6. 사례
{{case_links}}

## 7. 산출물
{{output_links}}

## 8. 온톨로지
- [[Ontology Nodes]]
- [[Ontology Edges]]
- [[Knowledge Graph]]

## 9. 검토 큐
- [[Review Items]]
```

---

## Phase 6: 온톨로지 구조 생성

### Step 6.1: 온톨로지 스키마 정의

**기본 구조:**
```text
주어 → 관계 → 목적어
Subject → Relation → Object
```

**예시:**
```text
MedVo → includes → AI상담통역
MedVo → solves → 외국인 환자 상담 문제
GEO-AIO → generates → 병원 콘텐츠
```

### Step 6.2: 온톨로지 노드 추출

**노드 유형:**
```text
Project, Concept, Problem, Solution, Function, Customer, Person, Company,
Methodology, Document, Output, KPI, Risk, Process, Market, Technology,
Case, Template, Reference
```

**노드 CSV 형식:**
```csv
node_id,label,type,domain,description,source_file,status,aliases,tags
```

**예시:**
```csv
node_id,label,type,domain,description,source_file,status,aliases,tags
N001,MedVo,Project,hospital_ai,병원 외국인 환자 유치 AI 운영체제,MedVo_제안서.docx,active,,hospital_ai;foreign_patient
N002,AI상담통역,Function,hospital_ai,외국인 환자를 위한 다국어 AI 상담 기능,MedVo_제안서.docx,active,AI consultation interpretation,hospital_ai;translation
```

**노드 생성 규칙:**
- 중복 노드는 병합합니다
- 동의어는 aliases에 등록합니다
- 원본 출처를 보존합니다
- 노드 유형을 지정합니다
- 상태값은 `active`, `review`, `deprecated`, `archive` 중 하나
- 한국어 원본은 한국어 라벨을 유지합니다
- 필요 시 영어 alias를 추가합니다

### Step 6.3: 온톨로지 관계 추출

**관계 유형:**
```text
includes, solves, causes, requires, applies_to, generates, improves, measures,
connected_to, belongs_to, part_of, derived_from, used_for, recommended_for,
competes_with, supports, depends_on, targets, created_by, owned_by,
evaluated_by, produces, reduces, increases
```

**엣지 CSV 형식:**
```csv
edge_id,source,relation,target,confidence,source_file,source_chunk,status
```

**예시:**
```csv
edge_id,source,relation,target,confidence,source_file,source_chunk,status
E001,MedVo,includes,AI상담통역,0.95,MedVo_제안서.docx,F001-C003,active
E002,MedVo,solves,외국인 환자 상담 문제,0.92,MedVo_제안서.docx,F001-C004,active
```

**관계 신뢰도 규칙:**
```text
0.90–1.00: 원문에 명시된 관계
0.70–0.89: 강하게 추론 가능한 관계
0.50–0.69: 약한 추론 관계, 검토 필요
0.50 미만: 사용자가 명시적으로 요구하지 않는 한 포함하지 않음
```

### Step 6.4: 온톨로지 JSON 생성

**출력 파일:** `{output_folder}/10_Ontology/ontology_graph.json`

**JSON 형식:**
```json
{
  "project": "{{project_name}}",
  "language": "{{language}}",
  "nodes": [
    {
      "id": "MedVo",
      "type": "Project",
      "domain": "hospital_ai",
      "description": "병원 외국인 환자 유치 AI 운영체제",
      "source_file": "MedVo_제안서.docx",
      "status": "active"
    }
  ],
  "edges": [
    {
      "source": "MedVo",
      "relation": "includes",
      "target": "AI상담통역",
      "confidence": 0.95,
      "source_file": "MedVo_제안서.docx"
    }
  ]
}
```

---

## Phase 7: 검토 큐 및 요약 보고서 생성

### Step 7.1: 검토 큐 생성

**검토 항목:**
```text
중복 노트, 불명확한 제목, 모호한 개념, 약한 관계, 출처 누락,
낮은 신뢰도 관계, 민감 정보, 오래된 문서, 충돌하는 버전,
너무 넓은 노드, 너무 잘게 쪼개진 노트
```

**출력 파일:** `{output_folder}/11_Review/review_queue.csv`

**형식:**
```csv
item_id,type,target,issue,recommendation,priority
R001,node,AI상담,개념이 너무 넓음,AI상담통역과 AI상담코칭으로 분리,high
R002,edge,MedVo-connected_to-GEO-AIO,추론 관계임,사람 검토 필요,medium
```

### Step 7.2: 최종 요약 보고서 생성

**출력 파일:** `{output_folder}/00_Index/knowledge_summary.md`

**템플릿:**
```markdown
# {{project_name}} 지식 전환 요약 보고서

## 1. 입력 폴더
{{input_folder}}

## 2. 출력 Vault
{{output_folder}}

## 3. 처리된 파일
- 전체 파일 수: {{file_count}}
- PDF: {{pdf_count}}
- DOCX: {{docx_count}}
- PPTX: {{pptx_count}}
- XLSX: {{xlsx_count}}
- TXT/MD/HTML: {{text_count}}
- 이미지: {{image_count}}

## 4. 생성된 노트
- 프로젝트: {{project_note_count}}
- 개념: {{concept_note_count}}
- 방법론: {{methodology_note_count}}
- 고객: {{customer_note_count}}
- 문서: {{document_note_count}}
- 사례: {{case_note_count}}

## 5. 온톨로지 결과
- 노드: {{node_count}}
- 관계: {{edge_count}}
- 검토 항목: {{review_count}}

## 6. 주요 지식 주제
{{main_themes}}

## 7. 강한 지식 영역
{{strong_areas}}

## 8. 약하거나 누락된 영역
{{weak_areas}}

## 9. 추천 산출물
{{recommended_outputs}}

## 10. 다음 실행 과제
{{next_actions}}
```

---

## Phase 7.5: 온톨로지 DB 고급 자료 생성 ⭐ NEW

이 단계에서는 온톨로지를 실제로 활용할 수 있는 4가지 고급 자료를 자동 생성합니다.

### Step 7.5.1: 인터랙티브 Graph 시각화 생성

**출력 파일**: `{output_folder}/10_Ontology/knowledge_graph.html`

D3.js 기반 인터랙티브 그래프 시각화를 생성합니다:

**기능**:
- Force-Directed Graph 레이아웃
- 노드 유형별 색상 구분
- 드래그 앤 드롭
- 줌/패닝
- 노드 클릭 시 상세 정보 표시
- 라벨 토글
- SVG 다운로드
- 통계 대시보드
- 범례

**구현 요소**:
```javascript
- D3.js v7 라이브러리 사용
- ontology_graph.json 데이터 로드
- 노드 유형별 색상 스킴 적용
- Force simulation 설정
- 사용자 인터랙션 구현
```

**색상 스킴**:
- Methodology: #667eea (보라)
- Concept: #48bb78 (녹색)
- Person: #ed8936 (주황)
- Company: #e53e3e (빨강)
- Function: #38b2ac (청록)
- Process: #d69e2e (노랑)
- Framework: #805ad5 (자주)
- Organization: #dd6b20 (갈색)

---

### Step 7.5.2: Neo4j Import 스크립트 생성

**출력 파일**: `{output_folder}/10_Ontology/neo4j_import.cypher`

Neo4j Graph DB에 바로 import할 수 있는 Cypher 스크립트를 생성합니다.

**포함 내용**:
1. Constraints 생성 (중복 방지)
2. 38개 노드 CREATE 문
3. 50개 관계 CREATE 문
4. 인덱스 생성 (성능 최적화)
5. 검증 쿼리

**노드 생성 패턴**:
```cypher
CREATE (:KnowledgeNode:Methodology {
  id: 'N001',
  label: 'GE 비즈니스 방법론',
  type: 'Methodology',
  domain: 'business_leadership',
  description: '...',
  source_file: '...',
  status: 'active',
  tags: ['GE', '비즈니스', '방법론']
});
```

**관계 생성 패턴**:
```cypher
MATCH (a:KnowledgeNode {id: 'N001'}), (b:KnowledgeNode {id: 'N002'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);
```

**검증 쿼리**:
- 전체 노드 수 확인
- 전체 관계 수 확인
- 유형별 통계
- 연결이 많은 노드 Top 10

---

### Step 7.5.3: Vector DB Setup 가이드 생성

**출력 파일**: `{output_folder}/10_Ontology/vector_db_setup.md`

RAG 챗봇 구축을 위한 완전한 Vector DB 구축 가이드를 생성합니다.

**포함 내용**:

1. **개요**
   - 목적: 의미 검색, RAG 챗봇
   - 추천 DB: Supabase pgvector, Pinecone, Weaviate

2. **데이터 구조**
   - PostgreSQL + pgvector 스키마
   - documents, chunks, knowledge_nodes, markdown_notes 테이블
   - vector(1536) 컬럼 (OpenAI ada-002)

3. **임베딩 생성 스크립트**
   - Python 코드 (OpenAI API)
   - Documents 임베딩
   - Knowledge Nodes 임베딩
   - Markdown Notes 임베딩

4. **검색 쿼리 예시**
   - Semantic Search 함수
   - Similarity 계산
   - Python 사용 예시

5. **RAG 챗봇 구축**
   - Next.js API Route 코드
   - 질문 임베딩 → 유사 지식 검색 → GPT 답변 생성

6. **실행 가이드**
   - 단계별 설치 및 실행
   - 환경 변수 설정

7. **예상 비용**
   - OpenAI Embeddings: ~$0.01
   - Supabase: 무료 티어

8. **고급 기능**
   - Hybrid Search (Keyword + Semantic)

---

### Step 7.5.4: Graph 분석 보고서 생성

**출력 파일**: `{output_folder}/10_Ontology/graph_analysis_report.md`

온톨로지 그래프의 구조적 분석 및 인사이트를 자동 생성합니다.

**포함 내용**:

1. **전체 통계**
   - 노드/엣지 수
   - 유형별 분포
   - 평균 연결도
   - 그래프 밀도

2. **중심성 분석 (Centrality Analysis)**
   - Degree Centrality Top 10
   - In-Degree / Out-Degree 분석
   - 가장 연결이 많은 노드 식별

3. **허브 노드 분석**
   - Primary Hubs (1차 허브)
   - Secondary Hubs (2차 허브)
   - 각 허브의 역할과 영향력

4. **클러스터 분석**
   - 의미 있는 클러스터 식별
   - Cluster 1: GE 비즈니스 방법론 코어
   - Cluster 2: 세일즈 영역
   - Cluster 3: 변화 리더십 영역
   - Cluster 4: 인재 육성 영역
   - Cluster 5: 인물 및 조직
   - Cluster 6: 소통 영역

5. **강한 연결 경로 (Strong Paths)**
   - Path 1: 저자 → 방법론 → 적용
   - Path 2: 리더 → 조직 → 산출물
   - Path 3: 역량 모델 → 교육 프로그램
   - Path 4: 리더십 프레임워크 → 개별 역량

6. **주요 인사이트**
   - 계층적 구조 발견
   - 중복 개념 발견
   - 저자의 영향력 분석
   - GE의 중심성
   - 약한 연결 영역

7. **그래프 품질 평가**
   - 강점 (명확한 계층, 강한 허브, 높은 신뢰도)
   - 약점 (중복 개념, 약한 연결, 부분 추출)
   - 개선 방향

8. **시각화 권장사항**
   - Force-Directed Graph
   - Hierarchical Tree
   - Sankey Diagram
   - Network Graph by Type

9. **그래프 메트릭**
   - 기본 메트릭 (N, E, Density)
   - 연결성 메트릭
   - 중심성 메트릭

10. **활용 제안**
    - 교육 프로그램 설계
    - 컨설팅 진단 도구
    - AI 챗봇 프롬프트
    - 지식 검색 전략

---

### Step 7.5.5: 4가지 파일 생성 확인

다음 4개 파일이 생성되었는지 확인:

```text
✅ knowledge_graph.html      (인터랙티브 시각화)
✅ neo4j_import.cypher       (Graph DB Import)
✅ vector_db_setup.md        (Vector DB 가이드)
✅ graph_analysis_report.md  (분석 보고서)
```

---

## Phase 8: 최종 검증 및 완료

### Step 8.1: 품질 체크리스트

다음 항목을 확인합니다:

```text
[ ] 입력 폴더가 정상적으로 스캔되었는가?
[ ] source_manifest.csv가 생성되었는가?
[ ] 메타데이터가 추출되었는가?
[ ] 본문이 추출되었는가?
[ ] 청크가 생성되었는가?
[ ] 지식 단위가 추출되었는가?
[ ] Markdown 노트가 생성되었는가?
[ ] 각 노트에 YAML frontmatter가 있는가?
[ ] 내부 링크가 생성되었는가?
[ ] 인덱스 페이지가 생성되었는가?
[ ] 온톨로지 노드가 생성되었는가?
[ ] 온톨로지 관계가 생성되었는가?
[ ] 신뢰도 점수가 부여되었는가?
[ ] review_queue.csv가 생성되었는가?
[ ] 원본 추적성이 보존되었는가?
[ ] knowledge_summary.md가 생성되었는가?
[ ] 출력 Vault가 Obsidian에서 열릴 수 있는가?

⭐ 온톨로지 DB 고급 자료 (NEW)
[ ] knowledge_graph.html이 생성되었는가?
[ ] neo4j_import.cypher가 생성되었는가?
[ ] vector_db_setup.md가 생성되었는가?
[ ] graph_analysis_report.md가 생성되었는가?
```

### Step 8.2: 사용자 보고

다음 정보를 사용자에게 보고합니다:

```text
✅ Wiki-Ontology Transformation 완료!

📊 실행 결과:
- Vault 경로: {output_folder}
- 처리된 파일: {file_count}개
- 생성된 노트: {note_count}개
- 온톨로지 노드: {node_count}개
- 온톨로지 관계: {edge_count}개
- 검토 항목: {review_count}개

📁 출력 파일:

기본 파일:
- Home.md (시작 페이지)
- knowledge_summary.md (전체 요약)
- source_manifest.csv (원본 파일 목록)
- ontology_nodes.csv (노드 데이터)
- ontology_edges.csv (엣지 데이터)
- ontology_graph.json (JSON 그래프)
- review_queue.csv (검토 항목)

⭐ 온톨로지 DB 고급 자료 (NEW):
- knowledge_graph.html (인터랙티브 그래프 시각화)
- neo4j_import.cypher (Neo4j Import 스크립트)
- vector_db_setup.md (Vector DB 구축 가이드)
- graph_analysis_report.md (그래프 분석 보고서)

🚀 다음 단계:

1. Obsidian Wiki 탐색:
   - Obsidian으로 {output_folder} 열기
   - Home.md에서 탐색 시작

2. 그래프 시각화:
   - knowledge_graph.html을 웹 브라우저에서 열기
   - 인터랙티브 그래프 탐색

3. Graph DB 구축:
   - Neo4j Desktop 설치
   - neo4j_import.cypher 실행

4. RAG 챗봇 구축:
   - vector_db_setup.md 가이드 따라하기
   - Supabase + OpenAI로 의미 검색 구현

5. 분석 보고서 읽기:
   - graph_analysis_report.md에서 인사이트 확인
   - 개선 방향 파악

6. 검토 및 보완:
   - review_queue.csv 검토
   - 우선순위 높은 항목부터 처리
```

---

## AI Agent 실행 규칙

이 스킬을 실행하는 AI Agent는 다음 규칙을 **반드시** 따라야 합니다:

### 규칙 1. 원본 추적성 보존
생성된 모든 노트, 노드, 엣지, 요약은 원본 파일과 위치로 추적 가능해야 합니다.

### 규칙 2. 사용자가 편집한 노트 덮어쓰기 금지
출력 Vault에 이미 사용자가 편집한 Markdown 노트가 있다면 덮어쓰지 말고 버전 파일을 생성합니다.

### 규칙 3. 사실과 추론 분리
원문에 있는 사실과 AI가 추론한 관계를 구분해야 합니다.

### 규칙 4. 불확실한 관계 표시
근거가 부족한 관계는 `review_queue.csv`에 넣습니다.

### 규칙 5. 한 노트에는 하나의 핵심 의미만 담기
각 Obsidian 노트는 하나의 주요 개념, 프로젝트, 방법, 고객, 문제, 산출물을 중심으로 작성합니다.

### 규칙 6. 무분별한 노트 폭증 방지
사용자가 아주 세밀한 분해를 요청하지 않는 한 너무 많은 미세 노트를 만들지 않습니다.

### 규칙 7. 한국어 용어 보존
원본 자료가 한국어라면 한국어 라벨을 유지하고, 필요한 경우에만 영어 alias를 추가합니다.

### 규칙 8. 사람이 읽기 좋은 위키 우선 생성
Obsidian Wiki는 기계만을 위한 데이터가 아니라 사람이 탐색하고 편집하기 좋은 지식 저장소여야 합니다.

### 규칙 9. AI가 읽기 좋은 온톨로지 생성
온톨로지는 AI Agent, Graph DB, 후속 애플리케이션이 활용할 수 있도록 구조화되어야 합니다.

### 규칙 10. 요약 보고서 반드시 생성
항상 `knowledge_summary.md`를 생성합니다.

---

## 실행 시작

이제 스킬을 실행합니다.

**Step 1:** 사용자에게 입력값을 확인합니다.
**Step 2:** 폴더를 스캔합니다.
**Step 3:** 파일을 분석합니다.
**Step 4:** Obsidian Wiki를 생성합니다.
**Step 5:** 온톨로지를 구축합니다.
**Step 6:** 검토 큐와 요약 보고서를 생성합니다.
**Step 7:** ⭐ 온톨로지 DB 고급 자료 생성 (NEW)
  - 7.1: 인터랙티브 Graph 시각화 (knowledge_graph.html)
  - 7.2: Neo4j Import 스크립트 (neo4j_import.cypher)
  - 7.3: Vector DB Setup 가이드 (vector_db_setup.md)
  - 7.4: Graph 분석 보고서 (graph_analysis_report.md)
**Step 8:** 사용자에게 결과를 보고합니다.

작업을 시작합니다.

---

## 📊 구체적인 결과물

### 1. Obsidian Wiki Vault (사람이 읽는 지식 저장소)

- **Markdown 노트 파일들**: 각 개념/프로젝트/인물마다 독립된 .md 파일
- **내부 링크로 연결된 지식 네트워크**: `[[링크]]` 문법으로 노트 간 연결
- **YAML frontmatter 메타데이터**: 제목, 타입, 도메인, 태그 등
- **Obsidian에서 바로 열어서 사용 가능**: 폴더를 Vault로 열기만 하면 됨

**예시 노트 구조:**
```markdown
---
title: GE 비즈니스 방법론
type: Methodology
domain: business_leadership
status: active
tags:
  - GE
  - 비즈니스
---

# GE 비즈니스 방법론

## 1. 한 줄 정의
...

## 7. 연결 노트
- [[세일즈 프로세스]]
- [[변화리더십 101]]
- [[4E + V]]
```

---

### 2. 온톨로지 지식 그래프 (기계가 읽는 구조화 데이터)

- **ontology_nodes.csv**: 개념/프로젝트/사람/회사 노드 (38개)
  ```csv
  node_id,label,type,domain,description,source_file,status
  N001,GE 비즈니스 방법론,Methodology,business_leadership,...
  ```

- **ontology_edges.csv**: 노드 간 관계 (50개) - 포함, 생성, 해결 등
  ```csv
  edge_id,source,relation,target,confidence,source_file
  E001,GE 비즈니스 방법론,포함,세일즈 프로세스,0.95,...
  ```

- **ontology_graph.json**: 전체 그래프 JSON 형식
  ```json
  {
    "nodes": [...],
    "edges": [...]
  }
  ```

---

### 3. ⭐ 인터랙티브 시각화

- **knowledge_graph.html**: D3.js 기반 인터랙티브 그래프
  - **노드 드래그**: 마우스로 노드 위치 조정
  - **줌/패닝**: 확대/축소 및 이동
  - **라벨 토글**: 라벨 표시/숨기기
  - **SVG 다운로드**: 그래프를 이미지로 저장
  - **노드 유형별 색상**: Methodology(보라), Concept(녹색), Person(주황)
  - **통계 대시보드**: 노드/엣지 수, 밀도 등

**활용:** 웹 브라우저에서 바로 열어서 지식 구조 탐색

---

### 4. ⭐ Graph DB Import

- **neo4j_import.cypher**: Neo4j에 바로 import
  - **Constraints**: 중복 방지 제약조건
  - **노드 CREATE**: 38개 노드 생성 쿼리
  - **관계 CREATE**: 50개 관계 생성 쿼리
  - **검증 쿼리**: 데이터 확인 쿼리

**사용법:**
```bash
# Neo4j Desktop에서 실행
MATCH (n) DETACH DELETE n;  # 기존 데이터 삭제
:source neo4j_import.cypher  # 스크립트 실행
```

**활용:** Graph DB로 복잡한 관계 쿼리, 경로 탐색, 추천 시스템

---

### 5. ⭐ Vector DB 가이드

- **vector_db_setup.md**: RAG 챗봇 구축 가이드
  - **Supabase pgvector 스키마**: PostgreSQL + 벡터 확장
  - **OpenAI 임베딩 스크립트**: Python 코드 포함
  - **검색 쿼리 예시**: Semantic Search 함수
  - **실행 가이드**: 단계별 설치 및 실행

**포함 내용:**
- 데이터베이스 스키마 설계
- 임베딩 생성 Python 스크립트
- 유사도 검색 쿼리
- RAG 챗봇 API 코드 (Next.js)
- 예상 비용 ($0.01)

**활용:** AI 챗봇이 지식 저장소를 검색하여 답변

---

### 6. ⭐ 분석 보고서

- **graph_analysis_report.md**
  - **전체 통계**: 노드 38개, 엣지 50개, 평균 연결도 2.6
  - **중심성 분석**: Degree Centrality Top 10
  - **허브 노드**: GE, 심재우, GE 비즈니스 방법론
  - **클러스터 분석**: 6개 클러스터 (세일즈, 리더십, 인재육성 등)
  - **강한 연결 경로**: 저자 → 방법론 → 적용
  - **인사이트**: 계층 구조, 중복 개념, 약한 연결 영역

**활용:** 지식 구조 이해, 교육 프로그램 설계, 컨설팅 진단

---

### 7. 검토 큐

- **review_queue.csv**: AI가 자동 검출한 문제점
  - **중복 노트**: 병합 필요
  - **불명확한 개념**: 정의 보완 필요
  - **약한 관계**: 신뢰도 낮은 추론
  - **우선순위**: high/medium/low

**예시:**
```csv
item_id,type,target,issue,recommendation,priority
R001,node,AI상담,개념이 너무 넓음,세분화 필요,high
R002,edge,MedVo-GEO-AIO,추론 관계,사람 검토 필요,medium
```

**활용:** 데이터 품질 개선, 우선순위 작업 파악

---

## 🎯 활용 방법

### 1. Obsidian으로 탐색
- Obsidian 실행 → "폴더를 Vault로 열기"
- `{output_folder}` 선택
- `Home.md`에서 탐색 시작
- 내부 링크 클릭하여 연결된 지식 탐색

### 2. 그래프 시각화
- `knowledge_graph.html`을 웹 브라우저에서 열기
- 노드를 드래그하여 배치 조정
- 클릭하여 상세 정보 확인
- SVG 다운로드로 이미지 저장

### 3. Graph DB 구축
- Neo4j Desktop 설치
- 새 데이터베이스 생성
- `neo4j_import.cypher` 실행
- Cypher 쿼리로 관계 탐색

### 4. RAG 챗봇 구축
- `vector_db_setup.md` 가이드 참조
- Supabase 프로젝트 생성
- OpenAI API 키 설정
- Python 스크립트로 임베딩 생성
- 챗봇 API 구축

### 5. 인사이트 확인
- `graph_analysis_report.md` 읽기
- 허브 노드 파악
- 클러스터 이해
- 약한 영역 보완

---

## 💡 최종 결과

**변환 전**: 흩어진 폴더 자료 (PDF, DOCX, PPTX 등)

**변환 후**:
1. ✅ 구조화된 Obsidian Wiki (사람이 읽기 좋음)
2. ✅ 온톨로지 지식 그래프 (기계가 읽기 좋음)
3. ✅ 인터랙티브 시각화 (탐색하기 좋음)
4. ✅ Graph DB Import (쿼리하기 좋음)
5. ✅ Vector DB + RAG (AI 활용하기 좋음)
6. ✅ 분석 보고서 (이해하기 좋음)
7. ✅ 검토 큐 (개선하기 좋음)

**활용 가능:**
- 📚 개인 지식 관리
- 🏢 기업 문서 관리
- 🤖 AI 챗봇 지식 베이스
- 📊 데이터 분석 및 시각화
- 🔍 의미 검색 시스템
- 📖 교육 자료 체계화

**결과**: 흩어진 자료 → 연결된 지식 운영체제 + AI 활용 준비 완료!
