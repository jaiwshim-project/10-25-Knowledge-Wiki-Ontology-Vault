#!/usr/bin/env node

/**
 * Claude Code CLI 프록시 서버
 * Knowledge Vault 챗봇이 Claude Code CLI를 백엔드로 사용
 *
 * 실행: node claude-proxy-server.js
 * 브라우저: http://localhost:3000
 */

const http = require('http');
const { exec } = require('child_process');
const fs = require('fs');
const path = require('path');

const PORT = 3000;
const VAULT_DIR = __dirname;

// CORS 허용 헤더
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Content-Type': 'application/json'
};

// Knowledge Vault 데이터 로드
function loadVaultData() {
  const vaultPath = path.join(VAULT_DIR, 'knowledge_vault_premium.html');
  const content = fs.readFileSync(vaultPath, 'utf-8');

  // VAULT_DATA 추출 (간단한 정규식)
  const match = content.match(/const VAULT_DATA = ({[\s\S]*?});/);
  if (match) {
    return eval(`(${match[1]})`); // 실제로는 JSON.parse 사용 권장
  }
  return null;
}

// 문서 검색
function searchDocuments(query, vaultData) {
  const results = [];
  const queryLower = query.toLowerCase();

  if (!vaultData || !vaultData.files) return [];

  for (const [folder, files] of Object.entries(vaultData.files)) {
    files.forEach(file => {
      if (file.content.toLowerCase().includes(queryLower) ||
          file.name.toLowerCase().includes(queryLower)) {
        results.push({
          folder,
          filename: file.name,
          content: file.content.substring(0, 2000) // 처음 2000자만
        });
      }
    });
  }

  return results.slice(0, 3); // 상위 3개
}

// Claude Code CLI 호출
async function callClaudeCLI(prompt) {
  return new Promise((resolve, reject) => {
    const { spawn } = require('child_process');

    // spawn으로 변경 (UTF-8 인코딩 보장)
    const claude = spawn('claude', [], {
      encoding: 'utf8',
      env: { ...process.env, LANG: 'en_US.UTF-8' }
    });

    let output = '';
    let errorOutput = '';

    claude.stdout.on('data', (data) => {
      output += data.toString('utf8');
    });

    claude.stderr.on('data', (data) => {
      errorOutput += data.toString('utf8');
    });

    claude.on('close', (code) => {
      if (code !== 0) {
        console.error('❌ Claude CLI Error:', errorOutput);
        reject(new Error(errorOutput || `Exit code: ${code}`));
        return;
      }

      resolve(output.trim());
    });

    // 프롬프트 전송
    claude.stdin.write(prompt, 'utf8');
    claude.stdin.end();
  });
}

// HTTP 서버
const server = http.createServer(async (req, res) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(200, CORS_HEADERS);
    res.end();
    return;
  }

  // POST /api/chat
  if (req.method === 'POST' && req.url === '/api/chat') {
    let body = '';

    req.on('data', chunk => {
      body += chunk.toString();
    });

    req.on('end', async () => {
      try {
        const { question } = JSON.parse(body);

        console.log(`\n📩 질문: ${question}`);

        // 1. Knowledge Vault 데이터 검색
        const vaultData = loadVaultData();
        const documents = searchDocuments(question, vaultData);

        console.log(`📄 검색된 문서: ${documents.length}개`);

        // 2. Context 구성
        const context = documents.map(doc => {
          const title = doc.content.match(/title:\s*(.+)/)?.[1] || doc.filename;
          return `[${title}]\n${doc.content}`;
        }).join('\n\n---\n\n');

        // 3. Claude CLI 프롬프트 구성
        const prompt = `당신은 Knowledge Vault AI 어시스턴트입니다.

아래는 Knowledge Vault의 관련 문서입니다:

${context}

사용자 질문: ${question}

위 문서를 기반으로 정확하고 상세한 답변을 제공하세요. 답변은 한국어로 작성하며, 가능하면 문서의 구체적인 내용을 인용하세요.`;

        console.log('🤖 Claude CLI 호출 중...');

        // 4. Claude CLI 호출
        const answer = await callClaudeCLI(prompt);

        console.log(`✅ 답변 생성 완료 (${answer.length}자)`);

        // 5. 응답
        const response = {
          answer,
          sources: documents.map(doc => ({
            type: 'file',
            title: doc.content.match(/title:\s*(.+)/)?.[1] || doc.filename,
            folder: doc.folder,
            filename: doc.filename
          }))
        };

        res.writeHead(200, CORS_HEADERS);
        res.end(JSON.stringify(response));

      } catch (error) {
        console.error('❌ 오류:', error);
        res.writeHead(500, CORS_HEADERS);
        res.end(JSON.stringify({
          error: '서버 오류가 발생했습니다.',
          details: error.message
        }));
      }
    });

    return;
  }

  // Health check
  if (req.url === '/health') {
    res.writeHead(200, CORS_HEADERS);
    res.end(JSON.stringify({ status: 'ok' }));
    return;
  }

  // 404
  res.writeHead(404, CORS_HEADERS);
  res.end(JSON.stringify({ error: 'Not Found' }));
});

server.listen(PORT, () => {
  console.log(`
╔════════════════════════════════════════════╗
║  Knowledge Vault Claude Proxy Server      ║
╚════════════════════════════════════════════╝

✅ 서버 시작: http://localhost:${PORT}
🤖 백엔드: Claude Code CLI
📚 데이터: Knowledge Vault

사용법:
  1. 이 서버를 실행 상태로 유지
  2. 브라우저에서 Knowledge Vault 열기
  3. 챗봇 사용 - 자동으로 CLI 호출

테스트:
  curl http://localhost:${PORT}/health

종료: Ctrl+C
`);
});

// 종료 시그널 처리
process.on('SIGINT', () => {
  console.log('\n\n👋 서버 종료 중...');
  server.close(() => {
    console.log('✅ 서버가 종료되었습니다.');
    process.exit(0);
  });
});
