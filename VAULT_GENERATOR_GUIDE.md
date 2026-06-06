# 📚 Knowledge Vault 자동 생성기 사용 가이드

폴더 경로만 입력하면 자동으로 MD 파일들을 스캔하여 **Knowledge Vault 플랫폼**으로 변환합니다.

---

## 🚀 빠른 시작

### 1. 기본 사용법

```bash
node vault-generator.js "폴더경로"
```

### 2. 예시

```bash
# Windows
node vault-generator.js "C:\Documents\MyNotes"

# macOS/Linux
node vault-generator.js "/Users/username/Documents/MyNotes"

# 현재 폴더
node vault-generator.js "."
```

---

## 📋 요구사항

### 필수
- **Node.js** 설치 (v14 이상)
- **MD 파일**이 있는 폴더

### 선택
- Frontmatter 메타데이터 (자동 추출)
- Wiki 링크 `[[링크]]` (온톨로지 자동 생성)

---

## 🎯 기능

### 1. 자동 스캔
- ✅ 폴더 재귀 탐색
- ✅ 모든 `.md`, `.markdown` 파일 발견
- ✅ `.git`, `node_modules` 자동 제외
- ✅ 폴더 구조 유지

### 2. 파일 파싱
```markdown
---
title: 문서 제목
type: Concept
tags: [태그1, 태그2]
---

# 본문 제목

본문 내용...

[[다른 문서]] 링크
```

**자동 추출:**
- `title`: Frontmatter > 첫 # 제목 > 파일명
- `type`: Frontmatter (없으면 "Document")
- `tags`: Frontmatter 배열
- `content`: 본문 전체
- `links`: `[[Wiki 링크]]` 자동 파싱

### 3. 온톨로지 생성
- **노드**: 각 MD 파일 = 1개 노드
- **엣지**: Wiki 링크 = 관계
- **ID**: 자동 생성 (N001, N002, ...)

### 4. Knowledge Vault 생성
- `generated_vault/knowledge_vault_premium.html`
- `generated_vault/vault_metadata.json`

---

## 📂 출력 구조

```
대상 폴더/
├── generated_vault/               ← 생성된 결과
│   ├── knowledge_vault_premium.html   ← Knowledge Vault
│   └── vault_metadata.json            ← 메타데이터
│
└── 원본 MD 파일들... (변경 없음)
```

---

## 🎨 Knowledge Vault 기능

생성된 `knowledge_vault_premium.html`은:

### ✅ Wiki 시스템
- 폴더 트리 네비게이션
- 탭 기반 멀티 파일 열기
- Markdown 렌더링
- 링크 클릭 네비게이션

### ✅ 온톨로지 그래프
- D3.js 인터랙티브 그래프
- 노드/엣지 시각화
- 관계 탐색

### ✅ 검색 기능
- 전체 문서 검색
- 실시간 결과 표시
- 파일 내용 미리보기

### ✅ AI 챗봇 (옵션)
- Claude CLI 통합
- RAG 기반 질문 답변
- 출처 문서 링크

---

## 📊 실행 예시

```bash
$ node vault-generator.js "C:\MyNotes"

╔════════════════════════════════════════════╗
║  Knowledge Vault 자동 생성기              ║
╚════════════════════════════════════════════╝

📁 대상 폴더: C:\MyNotes

🔍 MD 파일 스캔 중...
✅ 25개 파일 발견

📖 파일 파싱 중...
✅ 25개 파일 파싱 완료

🔗 온톨로지 생성 중...
✅ 25개 노드, 48개 엣지 생성

🎨 Knowledge Vault HTML 생성 중...
✅ Knowledge Vault 생성 완료

╔════════════════════════════════════════════╗
║  ✅ 생성 완료!                             ║
╚════════════════════════════════════════════╝

📊 통계:
  • 폴더: 5개
  • 파일: 25개
  • 노드: 25개
  • 엣지: 48개

📂 출력 위치:
  C:\MyNotes\generated_vault\knowledge_vault_premium.html

🌐 브라우저에서 열기:
  file:///C:/MyNotes/generated_vault/knowledge_vault_premium.html
```

---

## ⚙️ 설정 (고급)

`vault-generator.js` 파일 상단의 `CONFIG` 수정:

```javascript
const CONFIG = {
  supportedExtensions: ['.md', '.markdown'],  // 지원 확장자
  excludeFolders: ['node_modules', '.git'],   // 제외 폴더
  outputFolder: 'generated_vault',            // 출력 폴더명
  templateFile: 'knowledge_vault_premium.html' // 템플릿
};
```

---

## 🔧 Frontmatter 권장 형식

```yaml
---
title: 문서 제목
type: Concept | Methodology | Project | Person | Company
tags: [태그1, 태그2, 태그3]
created: 2026-06-06
status: active | draft | archived
domain: 도메인명
---
```

**필수 아님!** 없어도 자동 생성됩니다.

---

## 🎯 Wiki 링크 형식

### 기본 링크
```markdown
[[다른 문서]]
```

### 표시 텍스트 변경
```markdown
[[파일명|표시할 텍스트]]
```

### 섹션 링크
```markdown
[[문서#섹션]]
```

---

## 📝 사용 사례

### 사례 1: Obsidian Vault 변환
```bash
node vault-generator.js "C:\Obsidian\MyVault"
```
→ Obsidian 노트를 웹 Knowledge Vault로 변환

### 사례 2: 프로젝트 문서화
```bash
node vault-generator.js "C:\Projects\Documentation"
```
→ 프로젝트 문서를 인터랙티브 Wiki로

### 사례 3: 개인 지식 베이스
```bash
node vault-generator.js "C:\Personal\Notes"
```
→ 개인 노트를 온톨로지 그래프로 시각화

---

## 🐛 문제 해결

### 문제 1: "MD 파일을 찾을 수 없습니다"
**원인**: 폴더에 `.md` 파일 없음

**해결**:
```bash
# 파일 확인
dir "폴더경로\*.md" /s
```

### 문제 2: "템플릿 파일을 찾을 수 없습니다"
**원인**: `knowledge_vault_premium.html`이 같은 폴더에 없음

**해결**:
- `vault-generator.js`와 같은 폴더에 템플릿 배치
- 또는 `CONFIG.templateFile` 경로 수정

### 문제 3: 한글 깨짐
**원인**: 파일 인코딩

**해결**:
- MD 파일을 UTF-8로 저장
- BOM 없는 UTF-8 권장

---

## 🚀 다음 단계

### 생성된 Vault 사용
1. 브라우저에서 `knowledge_vault_premium.html` 열기
2. 폴더 트리에서 파일 탐색
3. 검색 기능으로 내용 찾기
4. 온톨로지 그래프 탐색

### GitHub Pages 배포
```bash
cd generated_vault
git init
git add .
git commit -m "Initial commit"
git push
```

### Claude 챗봇 활성화
```bash
# claude-proxy-server.js 복사
cp claude-proxy-server.js generated_vault/

# 서버 시작
node claude-proxy-server.js
```

---

## 💡 팁

### 1. 폴더 구조 유지
원본 폴더 구조가 Knowledge Vault의 폴더 트리에 반영됩니다.

### 2. Wiki 링크 활용
`[[링크]]`를 많이 사용하면 온톨로지 그래프가 풍부해집니다.

### 3. 메타데이터 활용
Frontmatter로 `type`, `tags`를 지정하면 분류가 명확해집니다.

### 4. 정기 재생성
내용 수정 후 다시 실행하면 업데이트됩니다.

---

## 📞 지원

- **버그 리포트**: GitHub Issues
- **기능 요청**: GitHub Discussions
- **문서**: README.md

---

**🎉 이제 어떤 MD 폴더든 Knowledge Vault로 변환할 수 있습니다!**
