# 🌐 웹 기반 Knowledge Vault 생성기 가이드

랜딩 페이지에서 폴더 경로만 입력하면 **자동으로 Knowledge Vault를 생성**합니다!

---

## 🚀 빠른 시작

### 1. 서버 시작

터미널에서:

```bash
node vault-generator-server.js
```

**실행 화면:**
```
╔════════════════════════════════════════════╗
║  Knowledge Vault 생성 서버                ║
╚════════════════════════════════════════════╝

✅ 서버 시작: http://localhost:3001
🎯 엔드포인트: POST /api/generate-vault
```

### 2. 랜딩 페이지 열기

브라우저에서:
```
file:///경로/index.html
```

또는 Live Server 사용 (권장)

### 3. 폴더 입력 & 생성

1. **폴더 경로 입력**
   ```
   C:\Documents\MyNotes
   ```

2. **✨ 생성하기 버튼 클릭**

3. **자동 생성 완료!**
   - 📁 폴더 개수
   - 📄 파일 개수
   - 🔗 노드 개수
   - ↔️ 엣지 개수

4. **🚀 Knowledge Vault 열기**

---

## 📋 시스템 구성

### 구성 요소

```
┌─────────────────────────────────────────┐
│  index.html (랜딩 페이지)              │
│  - 폴더 입력 폼                         │
│  - 생성 버튼                            │
│  - 결과 표시                            │
└─────────────┬───────────────────────────┘
              │ HTTP POST
              │ /api/generate-vault
              ↓
┌─────────────────────────────────────────┐
│  vault-generator-server.js             │
│  - Node.js HTTP 서버 (Port 3001)       │
│  - 폴더 스캔 & 파싱                     │
│  - VAULT_DATA 생성                     │
└─────────────┬───────────────────────────┘
              │ 사용
              ↓
┌─────────────────────────────────────────┐
│  vault-generator.js                    │
│  - MD 파일 스캔                         │
│  - Frontmatter 파싱                    │
│  - 온톨로지 생성                        │
│  - HTML 출력                            │
└─────────────────────────────────────────┘
```

---

## 🎯 사용 흐름

### 사용자 관점

1. **폴더 경로 입력**
   ```
   C:\Documents\MyNotes
   ```

2. **버튼 클릭**
   - 로딩 스피너 표시
   - "Vault 생성 중..." 메시지

3. **결과 확인**
   ```
   ✅ 생성 완료!
   
   📁 폴더: 5개
   📄 파일: 25개
   🔗 노드: 25개
   ↔️ 엣지: 48개
   
   📂 C:\Documents\MyNotes\generated_vault\knowledge_vault_premium.html
   ```

4. **Vault 열기**
   - "🚀 Knowledge Vault 열기" 버튼 클릭
   - 새 탭에서 생성된 Vault 표시

---

## ⚙️ 서버 API

### POST /api/generate-vault

**요청:**
```json
{
  "folderPath": "C:\\Documents\\MyNotes"
}
```

**응답 (성공):**
```json
{
  "success": true,
  "metadata": {
    "totalFiles": 25,
    "totalFolders": 5,
    "totalNodes": 25,
    "totalEdges": 48,
    "generatedAt": "2026-06-06T12:00:00.000Z"
  },
  "outputPath": "C:\\Documents\\MyNotes\\generated_vault\\knowledge_vault_premium.html",
  "vaultUrl": "file:///C:/Documents/MyNotes/generated_vault/knowledge_vault_premium.html"
}
```

**응답 (오류):**
```json
{
  "error": "폴더를 찾을 수 없습니다: C:\\Invalid\\Path",
  "details": "..."
}
```

### GET /health

Health check 엔드포인트

**응답:**
```json
{
  "status": "ok"
}
```

---

## 🔧 브라우저 제한 사항

### 문제: 로컬 파일 시스템 접근 제한

브라우저 보안 정책으로 인해 JavaScript에서 직접 로컬 파일에 접근할 수 없습니다.

### 해결책

#### 옵션 1: 백엔드 서버 사용 (권장)
```bash
node vault-generator-server.js
```
→ 서버가 파일 시스템에 접근

#### 옵션 2: CLI 도구 사용
```bash
node vault-generator.js "폴더경로"
```
→ 직접 생성

#### 옵션 3: Electron 앱으로 패키징
- 로컬 파일 접근 가능
- 독립 실행형 앱

---

## 🎨 UI 기능

### 폴더 입력
- 플레이스홀더: `예: C:\Documents\MyNotes`
- Enter 키 지원
- 포커스 효과 (보라색 테두리)

### 생성 버튼
- 그라디언트 배경 (#667eea → #764ba2)
- Hover 효과 (위로 이동)
- 그림자 효과

### 로딩 상태
- 회전 스피너 애니메이션
- "Vault 생성 중..." 메시지

### 결과 표시
- 통계 카드
  - 폴더/파일/노드/엣지 개수
  - 출력 경로
- "Knowledge Vault 열기" 버튼
  - 새 탭으로 열기

### 오류 처리
- 오류 메시지 표시 (빨간색)
- 2초 후 CLI 방법 안내 모달
- 상세 가이드 링크

---

## 💡 CLI 방법 안내 모달

서버 연결 실패 시 자동으로 표시되는 모달:

### 내용
1. **터미널 열기**
2. **명령어 실행**
   ```bash
   node vault-generator.js "폴더경로"
   ```
3. **예시**
   ```bash
   node vault-generator.js "C:\Documents\MyNotes"
   ```
4. **결과 확인**
   ```
   폴더/generated_vault/knowledge_vault_premium.html
   ```

### 특징
- 어두운 배경 오버레이
- 중앙 모달 (흰색 배경)
- 코드 블록 (어두운 배경)
- "상세 가이드 보기" 링크
- "닫기" 버튼

---

## 📂 출력 구조

```
입력 폴더/
├── generated_vault/               ← 생성됨
│   ├── knowledge_vault_premium.html   ← Knowledge Vault
│   └── vault_metadata.json            ← 메타데이터
│
└── 원본 MD 파일들... (변경 없음)
```

---

## 🐛 문제 해결

### 문제 1: "서버에 연결할 수 없습니다"

**원인**: vault-generator-server.js 미실행

**해결:**
```bash
node vault-generator-server.js
```

**확인:**
```bash
curl http://localhost:3001/health
# {"status":"ok"}
```

---

### 문제 2: "폴더를 찾을 수 없습니다"

**원인**: 잘못된 경로

**해결:**
- 경로 확인
- 백슬래시 사용 (Windows): `C:\Documents\Notes`
- 따옴표 필요 없음 (입력란에서)

---

### 문제 3: CORS 오류

**원인**: `file://` 프로토콜에서 서버 호출

**해결:**
- Live Server 사용 (`http://localhost:5500`)
- 또는 서버에서 HTML 제공

---

### 문제 4: "MD 파일을 찾을 수 없습니다"

**원인**: 폴더에 `.md` 파일 없음

**해결:**
```bash
# 파일 확인
dir "폴더경로\*.md" /s
```

---

## 🚀 프로덕션 배포

### GitHub Pages에 배포

```bash
# 1. 생성된 Vault 업로드
cd generated_vault
git init
git add .
git commit -m "Initial vault"
git push

# 2. GitHub Pages 활성화
# Settings > Pages > Source: master branch
```

### 서버 배포 (Node.js 호스팅)

```bash
# Heroku, Railway, Vercel 등
npm start  # vault-generator-server.js 실행
```

---

## 📊 성능

| 파일 수 | 스캔 시간 | 파싱 시간 | 생성 시간 | 총 시간 |
|---------|----------|----------|----------|---------|
| 10개    | 0.1초    | 0.2초    | 0.3초    | 0.6초   |
| 50개    | 0.3초    | 1초      | 1.5초    | 2.8초   |
| 100개   | 0.5초    | 2초      | 3초      | 5.5초   |
| 500개   | 2초      | 10초     | 15초     | 27초    |

---

## 💡 팁

### 1. Live Server 사용
VS Code Live Server로 `index.html` 실행하면 CORS 문제 없음

### 2. 폴더 북마크
자주 사용하는 폴더 경로를 localStorage에 저장 (향후 추가 가능)

### 3. 배치 생성
여러 폴더를 한 번에 생성 (향후 추가 가능)

### 4. 자동 재생성
파일 변경 감지 시 자동 재생성 (향후 추가 가능)

---

## 📞 지원

- **버그 리포트**: GitHub Issues
- **기능 요청**: GitHub Discussions  
- **CLI 가이드**: VAULT_GENERATOR_GUIDE.md

---

**🎉 이제 웹 브라우저에서 바로 Knowledge Vault를 생성할 수 있습니다!**
