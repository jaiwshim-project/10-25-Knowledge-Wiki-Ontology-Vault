#!/usr/bin/env node

/**
 * Knowledge Vault 자동 생성기
 *
 * 사용법:
 *   node vault-generator.js "C:\경로\폴더명"
 *
 * 기능:
 * - MD 파일 자동 스캔
 * - Frontmatter 파싱 (title, tags, type 등)
 * - Wiki 링크 추출 [[링크]]
 * - 온톨로지 관계 분석
 * - VAULT_DATA 자동 생성
 * - knowledge_vault_premium.html 생성
 */

const fs = require('fs');
const path = require('path');

// ==================== 설정 ====================
const CONFIG = {
  supportedExtensions: ['.md', '.markdown'],
  excludeFolders: ['node_modules', '.git', '.obsidian'],
  outputFolder: 'generated_vault',
  templateFile: 'knowledge_vault_premium.html'
};

// ==================== 유틸리티 ====================

/**
 * Frontmatter 파싱
 */
function parseFrontmatter(content) {
  const frontmatterRegex = /^---\s*\n([\s\S]*?)\n---\s*\n/;
  const match = content.match(frontmatterRegex);

  if (!match) return { frontmatter: {}, content };

  const frontmatterText = match[1];
  const restContent = content.slice(match[0].length);

  const frontmatter = {};
  frontmatterText.split('\n').forEach(line => {
    const colonIndex = line.indexOf(':');
    if (colonIndex > 0) {
      const key = line.slice(0, colonIndex).trim();
      let value = line.slice(colonIndex + 1).trim();

      // 배열 처리 (tags 등)
      if (value.startsWith('[') && value.endsWith(']')) {
        value = value.slice(1, -1).split(',').map(v => v.trim());
      }

      frontmatter[key] = value;
    }
  });

  return { frontmatter, content: restContent };
}

/**
 * Wiki 링크 추출 [[링크]]
 */
function extractWikiLinks(content) {
  const linkRegex = /\[\[([^\]]+)\]\]/g;
  const links = [];
  let match;

  while ((match = linkRegex.exec(content)) !== null) {
    links.push(match[1]);
  }

  return links;
}

/**
 * 폴더 재귀 스캔
 */
function scanFolder(folderPath, basePath = folderPath) {
  const files = [];

  try {
    const items = fs.readdirSync(folderPath);

    for (const item of items) {
      const fullPath = path.join(folderPath, item);
      const stat = fs.statSync(fullPath);

      if (stat.isDirectory()) {
        // 제외 폴더 체크
        if (CONFIG.excludeFolders.includes(item)) continue;

        // 재귀 스캔
        files.push(...scanFolder(fullPath, basePath));
      } else if (stat.isFile()) {
        const ext = path.extname(item);
        if (CONFIG.supportedExtensions.includes(ext)) {
          files.push({
            fullPath,
            relativePath: path.relative(basePath, fullPath),
            folder: path.relative(basePath, path.dirname(fullPath)) || 'Root',
            filename: item,
            size: stat.size
          });
        }
      }
    }
  } catch (error) {
    console.error(`❌ 폴더 스캔 오류: ${folderPath}`, error.message);
  }

  return files;
}

/**
 * MD 파일 파싱
 */
function parseMarkdownFile(fileInfo) {
  try {
    const content = fs.readFileSync(fileInfo.fullPath, 'utf-8');
    const { frontmatter, content: bodyContent } = parseFrontmatter(content);
    const links = extractWikiLinks(content);

    // 제목 추출 (frontmatter > 첫 # 제목 > 파일명)
    let title = frontmatter.title;
    if (!title) {
      const titleMatch = bodyContent.match(/^#\s+(.+)$/m);
      title = titleMatch ? titleMatch[1] : path.basename(fileInfo.filename, path.extname(fileInfo.filename));
    }

    return {
      ...fileInfo,
      title,
      frontmatter,
      content: bodyContent.trim(),
      links,
      type: frontmatter.type || 'Document',
      tags: frontmatter.tags || []
    };
  } catch (error) {
    console.error(`❌ 파일 파싱 오류: ${fileInfo.fullPath}`, error.message);
    return null;
  }
}

/**
 * VAULT_DATA 생성
 */
function generateVaultData(parsedFiles) {
  // 폴더별 그룹화
  const filesByFolder = {};

  parsedFiles.forEach(file => {
    if (!filesByFolder[file.folder]) {
      filesByFolder[file.folder] = [];
    }

    filesByFolder[file.folder].push({
      name: file.filename,
      title: file.title,
      content: file.content,
      type: file.type,
      tags: file.tags,
      links: file.links
    });
  });

  // 온톨로지 노드 생성
  const nodes = parsedFiles.map((file, index) => ({
    id: `N${String(index + 1).padStart(3, '0')}`,
    label: file.title,
    type: file.type,
    folder: file.folder,
    filename: file.filename
  }));

  // 온톨로지 엣지 생성 (Wiki 링크 기반)
  const edges = [];
  parsedFiles.forEach((file, index) => {
    const sourceId = `N${String(index + 1).padStart(3, '0')}`;

    file.links.forEach(linkText => {
      // 링크 대상 파일 찾기
      const targetIndex = parsedFiles.findIndex(f =>
        f.title === linkText ||
        f.filename === linkText ||
        f.filename === `${linkText}.md`
      );

      if (targetIndex >= 0) {
        const targetId = `N${String(targetIndex + 1).padStart(3, '0')}`;
        edges.push({
          source: sourceId,
          target: targetId,
          relation: 'links_to'
        });
      }
    });
  });

  return {
    files: filesByFolder,
    ontology: {
      nodes,
      edges
    },
    metadata: {
      totalFiles: parsedFiles.length,
      totalFolders: Object.keys(filesByFolder).length,
      generatedAt: new Date().toISOString(),
      totalNodes: nodes.length,
      totalEdges: edges.length
    }
  };
}

/**
 * HTML 생성
 */
function generateHTML(vaultData, targetFolder) {
  const templatePath = path.join(__dirname, CONFIG.templateFile);

  if (!fs.existsSync(templatePath)) {
    console.error(`❌ 템플릿 파일을 찾을 수 없습니다: ${templatePath}`);
    return false;
  }

  let template = fs.readFileSync(templatePath, 'utf-8');

  // VAULT_DATA 교체
  const vaultDataString = `const VAULT_DATA = ${JSON.stringify(vaultData, null, 2)};`;
  template = template.replace(/const VAULT_DATA = {[\s\S]*?};/, vaultDataString);

  // 출력 폴더 생성
  const outputPath = path.join(targetFolder, CONFIG.outputFolder);
  if (!fs.existsSync(outputPath)) {
    fs.mkdirSync(outputPath, { recursive: true });
  }

  // HTML 저장
  const outputFile = path.join(outputPath, 'knowledge_vault_premium.html');
  fs.writeFileSync(outputFile, template, 'utf-8');

  console.log(`✅ Knowledge Vault 생성 완료: ${outputFile}`);

  // 메타데이터 JSON 저장
  const metaFile = path.join(outputPath, 'vault_metadata.json');
  fs.writeFileSync(metaFile, JSON.stringify(vaultData.metadata, null, 2), 'utf-8');

  return outputFile;
}

// ==================== 메인 실행 ====================

function main() {
  console.log(`
╔════════════════════════════════════════════╗
║  Knowledge Vault 자동 생성기              ║
╚════════════════════════════════════════════╝
  `);

  // 인자 확인
  const targetFolder = process.argv[2];

  if (!targetFolder) {
    console.error('❌ 사용법: node vault-generator.js "폴더경로"');
    console.error('예시: node vault-generator.js "C:\\Documents\\MyNotes"');
    process.exit(1);
  }

  if (!fs.existsSync(targetFolder)) {
    console.error(`❌ 폴더를 찾을 수 없습니다: ${targetFolder}`);
    process.exit(1);
  }

  console.log(`📁 대상 폴더: ${targetFolder}\n`);

  // 1. 폴더 스캔
  console.log('🔍 MD 파일 스캔 중...');
  const files = scanFolder(targetFolder);
  console.log(`✅ ${files.length}개 파일 발견\n`);

  if (files.length === 0) {
    console.error('❌ MD 파일을 찾을 수 없습니다.');
    process.exit(1);
  }

  // 2. 파일 파싱
  console.log('📖 파일 파싱 중...');
  const parsedFiles = files.map(parseMarkdownFile).filter(f => f !== null);
  console.log(`✅ ${parsedFiles.length}개 파일 파싱 완료\n`);

  // 3. VAULT_DATA 생성
  console.log('🔗 온톨로지 생성 중...');
  const vaultData = generateVaultData(parsedFiles);
  console.log(`✅ ${vaultData.ontology.nodes.length}개 노드, ${vaultData.ontology.edges.length}개 엣지 생성\n`);

  // 4. HTML 생성
  console.log('🎨 Knowledge Vault HTML 생성 중...');
  const outputFile = generateHTML(vaultData, targetFolder);

  if (outputFile) {
    console.log(`
╔════════════════════════════════════════════╗
║  ✅ 생성 완료!                             ║
╚════════════════════════════════════════════╝

📊 통계:
  • 폴더: ${vaultData.metadata.totalFolders}개
  • 파일: ${vaultData.metadata.totalFiles}개
  • 노드: ${vaultData.metadata.totalNodes}개
  • 엣지: ${vaultData.metadata.totalEdges}개

📂 출력 위치:
  ${outputFile}

🌐 브라우저에서 열기:
  file:///${outputFile.replace(/\\/g, '/')}
    `);
  }
}

// 실행
if (require.main === module) {
  main();
}

module.exports = { scanFolder, parseMarkdownFile, generateVaultData };
