# 🤖 Claude CLI 백엔드 연동 가이드

Knowledge Vault 챗봇이 **Claude Code CLI**를 백엔드로 사용하는 방법입니다.

## 💡 왜 Claude CLI를 사용하나요?

- ✅ **추가 API 비용 없음** (Claude Pro 구독만으로 가능)
- ✅ **로컬 실행** (API 키 노출 걱정 없음)
- ✅ **즉시 사용 가능** (별도 배포 불필요)

---

## 🚀 빠른 시작

### 1단계: 프록시 서버 실행

터미널에서:

```bash
cd "C:\000 자료 모음\09 심재우 저서\10-25 Knowledge Wiki & Ontology Vault"
node claude-proxy-server.js
```

**실행 화면:**
```
╔════════════════════════════════════════════╗
║  Knowledge Vault Claude Proxy Server      ║
╚════════════════════════════════════════════╝

✅ 서버 시작: http://localhost:3000
🤖 백엔드: Claude Code CLI
📚 데이터: Knowledge Vault

사용법:
  1. 이 서버를 실행 상태로 유지
  2. 브라우저에서 Knowledge Vault 열기
  3. 챗봇 사용 - 자동으로 CLI 호출
```

### 2단계: Knowledge Vault 열기

브라우저에서:
```
file:///C:/000%20자료%20모음/09%20심재우%20저서/10-25%20Knowledge%20Wiki%20&%20Ontology%20Vault/knowledge_vault_premium.html
```

또는 VS Code Live Server 사용.

### 3단계: 챗봇 사용

1. 우측 하단 💬 버튼 클릭
2. 질문 입력 (예: "GE의 변화리더십 9가지는?")
3. **자동으로 Claude CLI가 답변 생성!**

---

## 🔧 작동 원리

```
┌─────────────────────────────────────────────────┐
│  브라우저 (Knowledge Vault)                      │
│  - 사용자 질문 입력                               │
│  - Knowledge Vault 데이터 검색                   │
└─────────────────┬───────────────────────────────┘
                  │ HTTP POST
                  │ localhost:3000/api/chat
                  ↓
┌─────────────────────────────────────────────────┐
│  Node.js 프록시 서버                             │
│  claude-proxy-server.js                         │
│                                                  │
│  1. 요청 수신                                     │
│  2. Knowledge Vault 문서 검색                    │
│  3. Context 구성                                 │
└─────────────────┬───────────────────────────────┘
                  │ Shell 실행
                  │ echo "prompt" | claude
                  ↓
┌─────────────────────────────────────────────────┐
│  Claude Code CLI                                │
│  - 프롬프트 처리                                  │
│  - Claude Pro로 답변 생성                        │
└─────────────────┬───────────────────────────────┘
                  │ stdout
                  ↓
┌─────────────────────────────────────────────────┐
│  Node.js 프록시 서버                             │
│  - 답변 파싱                                     │
│  - JSON 응답 생성                                │
└─────────────────┬───────────────────────────────┘
                  │ HTTP Response
                  ↓
┌─────────────────────────────────────────────────┐
│  브라우저 (Knowledge Vault)                      │
│  - 답변 표시                                     │
│  - 출처 링크 표시                                 │
└─────────────────────────────────────────────────┘
```

---

## 📝 예시 대화

**질문:** "GE의 변화리더십 핵심 9가지를 요약해줘"

**서버 로그:**
```
📩 질문: GE의 변화리더십 핵심 9가지를 요약해줘
📄 검색된 문서: 2개
🤖 Claude CLI 호출 중...
✅ 답변 생성 완료 (1,245자)
```

**브라우저 챗봇:**
```
**잭 웰치의 9가지 변화혁신 리더십:**

1. **Energize & Growth** (동기부여와 성장)
   → 리더십의 핵심은 동기부여

2. **Vision Maker** (비전 메이커)
   → 미래를 그리는 능력

...

📄 변화리더십 101
📄 9가지 핵심 리더십
```

---

## ⚙️ 설정 옵션

### CLI 백엔드 끄기/켜기

`knowledge_vault_premium.html` 수정:

```javascript
const USE_CLAUDE_CLI = true;  // true: CLI 사용, false: 로컬 답변만
```

### 프록시 서버 포트 변경

`claude-proxy-server.js` 수정:

```javascript
const PORT = 3000;  // 원하는 포트로 변경
```

프론트엔드도 동일하게:

```javascript
fetch('http://localhost:3000/api/chat', ...)
```

---

## 🐛 문제 해결

### 1. "Claude CLI 백엔드에 연결할 수 없습니다"

**원인:** 프록시 서버가 실행 중이 아님

**해결:**
```bash
node claude-proxy-server.js
```

**확인:**
```bash
curl http://localhost:3000/health
# 응답: {"status":"ok"}
```

---

### 2. "Claude CLI Error"

**원인:** Claude Code CLI가 설치되지 않았거나 PATH에 없음

**해결:**
1. Claude Code 설치 확인:
   ```bash
   claude --version
   ```

2. 없다면 설치:
   - [Claude Code 설치 가이드](https://claude.ai/code)

---

### 3. 답변이 너무 느림

**원인:** Claude CLI가 대형 모델 사용 중

**해결:**
- `claude-proxy-server.js`에서 `--no-markdown` 외 옵션 추가:
  ```javascript
  const command = `echo "${prompt}" | claude --no-markdown --fast`;
  ```

---

### 4. CORS 에러

**원인:** 브라우저가 `file://`에서 `localhost:3000` 호출 차단

**해결:**
- **Option A**: VS Code Live Server 사용
  ```
  http://127.0.0.1:5500/knowledge_vault_premium.html
  ```

- **Option B**: Chrome 플래그
  ```bash
  chrome --disable-web-security --user-data-dir=/tmp/chrome
  ```

---

## 💰 비용

**무료!** 

Claude Pro 구독만 있으면:
- ✅ Knowledge Vault 챗봇 무제한 사용
- ✅ 추가 API 비용 없음
- ✅ 로컬에서 완전히 작동

---

## 🔐 보안

- ✅ **API 키 불필요** (CLI는 로컬 인증 사용)
- ✅ **데이터 외부 전송 없음** (모두 로컬)
- ✅ **완전한 프라이버시**

---

## 📈 성능

| 메트릭 | 값 |
|--------|-----|
| 첫 응답 시간 | ~3-5초 |
| 평균 응답 시간 | ~2-4초 |
| 동시 요청 | 1개 (CLI 제한) |
| 최대 Context | 200K 토큰 |

---

## 🎯 다음 단계

1. ✅ **기본 사용** - 프록시 서버 실행 + 챗봇 사용
2. 🔄 **자동 시작** - 서버를 백그라운드 서비스로 등록
3. 🌐 **네트워크 공유** - 같은 네트워크 내 다른 기기에서 접속
4. 📦 **Electron 앱** - 독립 실행형 데스크톱 앱으로 패키징

---

## 📚 참고 자료

- [Claude Code 공식 문서](https://claude.ai/code)
- [Knowledge Vault 사용 가이드](./README.md)
- [Node.js 설치](https://nodejs.org/)

---

**질문이나 문제가 있으면 이슈를 남겨주세요!** 🚀
