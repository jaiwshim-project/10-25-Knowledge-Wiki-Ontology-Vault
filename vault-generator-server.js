#!/usr/bin/env node

/**
 * Knowledge Vault 생성 서버
 *
 * 랜딩 페이지에서 폴더 입력 → 자동으로 Knowledge Vault 생성
 *
 * 실행:
 *   node vault-generator-server.js
 *
 * 엔드포인트:
 *   POST /api/generate-vault
 *   Body: { folderPath: "C:\\폴더경로" }
 */

const http = require('http');
const fs = require('fs');
const path = require('path');
const { scanFolder, parseMarkdownFile, generateVaultData } = require('./vault-generator');

const PORT = 3001;

// CORS 헤더
const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type',
  'Content-Type': 'application/json'
};

/**
 * HTML 생성 (vault-generator.js에서 가져온 로직)
 */
function generateHTML(vaultData, targetFolder) {
  const templatePath = path.join(__dirname, 'knowledge_vault_premium.html');

  if (!fs.existsSync(templatePath)) {
    throw new Error(`템플릿 파일을 찾을 수 없습니다: ${templatePath}`);
  }

  let template = fs.readFileSync(templatePath, 'utf-8');

  // VAULT_DATA 교체
  const vaultDataString = `const VAULT_DATA = ${JSON.stringify(vaultData, null, 2)};`;
  template = template.replace(/const VAULT_DATA = {[\s\S]*?};/, vaultDataString);

  // 출력 폴더 생성
  const outputPath = path.join(targetFolder, 'generated_vault');
  if (!fs.existsSync(outputPath)) {
    fs.mkdirSync(outputPath, { recursive: true });
  }

  // HTML 저장
  const outputFile = path.join(outputPath, 'knowledge_vault_premium.html');
  fs.writeFileSync(outputFile, template, 'utf-8');

  // 메타데이터 JSON 저장
  const metaFile = path.join(outputPath, 'vault_metadata.json');
  fs.writeFileSync(metaFile, JSON.stringify(vaultData.metadata, null, 2), 'utf-8');

  return { outputFile, outputPath };
}

/**
 * Vault 생성 처리
 */
async function handleGenerateVault(folderPath) {
  console.log(`\n📁 요청 받음: ${folderPath}`);

  // 폴더 존재 확인
  if (!fs.existsSync(folderPath)) {
    throw new Error(`폴더를 찾을 수 없습니다: ${folderPath}`);
  }

  // 1. 폴더 스캔
  console.log('🔍 MD 파일 스캔 중...');
  const files = scanFolder(folderPath);
  console.log(`✅ ${files.length}개 파일 발견`);

  if (files.length === 0) {
    throw new Error('MD 파일을 찾을 수 없습니다.');
  }

  // 2. 파일 파싱
  console.log('📖 파일 파싱 중...');
  const parsedFiles = files.map(parseMarkdownFile).filter(f => f !== null);
  console.log(`✅ ${parsedFiles.length}개 파일 파싱 완료`);

  // 3. VAULT_DATA 생성
  console.log('🔗 온톨로지 생성 중...');
  const vaultData = generateVaultData(parsedFiles);
  console.log(`✅ ${vaultData.ontology.nodes.length}개 노드, ${vaultData.ontology.edges.length}개 엣지 생성`);

  // 4. HTML 생성
  console.log('🎨 Knowledge Vault HTML 생성 중...');
  const { outputFile, outputPath } = generateHTML(vaultData, folderPath);
  console.log(`✅ 생성 완료: ${outputFile}`);

  return {
    success: true,
    metadata: vaultData.metadata,
    outputPath: outputFile,
    vaultUrl: `file:///${outputFile.replace(/\\/g, '/')}`
  };
}

// HTTP 서버
const server = http.createServer(async (req, res) => {
  // CORS preflight
  if (req.method === 'OPTIONS') {
    res.writeHead(200, CORS_HEADERS);
    res.end();
    return;
  }

  // POST /api/generate-vault
  if (req.method === 'POST' && req.url === '/api/generate-vault') {
    let body = '';

    req.on('data', chunk => {
      body += chunk.toString();
    });

    req.on('end', async () => {
      try {
        const { folderPath } = JSON.parse(body);

        if (!folderPath) {
          res.writeHead(400, CORS_HEADERS);
          res.end(JSON.stringify({ error: 'folderPath is required' }));
          return;
        }

        // Vault 생성
        const result = await handleGenerateVault(folderPath);

        res.writeHead(200, CORS_HEADERS);
        res.end(JSON.stringify(result));

      } catch (error) {
        console.error('❌ 오류:', error);
        res.writeHead(500, CORS_HEADERS);
        res.end(JSON.stringify({
          error: error.message,
          details: error.stack
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
║  Knowledge Vault 생성 서버                ║
╚════════════════════════════════════════════╝

✅ 서버 시작: http://localhost:${PORT}
🎯 엔드포인트: POST /api/generate-vault

사용법:
  1. 이 서버를 실행 상태로 유지
  2. 랜딩 페이지(index.html)에서 폴더 입력
  3. 자동으로 Knowledge Vault 생성

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
