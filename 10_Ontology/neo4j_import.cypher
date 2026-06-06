// ============================================================
// Neo4j Import Script
// 심재우 저서 Knowledge Graph
// ============================================================
//
// 실행 방법:
// 1. Neo4j Desktop에서 데이터베이스 생성
// 2. Neo4j Browser를 열고 이 파일의 내용을 복사
// 3. 순차적으로 실행
//
// 또는 cypher-shell 사용:
// cat neo4j_import.cypher | cypher-shell -u neo4j -p password
// ============================================================

// 1단계: 기존 데이터 삭제 (선택사항 - 주의!)
// MATCH (n) DETACH DELETE n;

// 2단계: Constraints 생성 (중복 방지)
CREATE CONSTRAINT node_id IF NOT EXISTS FOR (n:KnowledgeNode) REQUIRE n.id IS UNIQUE;
CREATE CONSTRAINT person_id IF NOT EXISTS FOR (p:Person) REQUIRE p.id IS UNIQUE;
CREATE CONSTRAINT company_id IF NOT EXISTS FOR (c:Company) REQUIRE c.id IS UNIQUE;
CREATE CONSTRAINT concept_id IF NOT EXISTS FOR (cn:Concept) REQUIRE cn.id IS UNIQUE;

// 3단계: 노드 생성 (38개)

// Methodology 노드 (3개)
CREATE (:KnowledgeNode:Methodology {
  id: 'N001',
  label: 'GE 비즈니스 방법론',
  type: 'Methodology',
  domain: 'business_leadership',
  description: 'General Electric의 세일즈-리더십-인재육성 통합 방법론',
  source_file: '서적 4 - GE의 세일즈 노트.pdf',
  status: 'active',
  tags: ['GE', '비즈니스', '방법론']
});

CREATE (:KnowledgeNode:Methodology {
  id: 'N002',
  label: '세일즈 프로세스 13가지 성공법칙',
  type: 'Methodology',
  domain: 'sales',
  description: 'GE 프로들이 사용하는 13가지 세일즈 성공 법칙 체계',
  source_file: '서적 4 - GE의 세일즈 노트.pdf',
  status: 'active',
  tags: ['세일즈', '성공법칙', 'GE']
});

CREATE (:KnowledgeNode:Methodology {
  id: 'N003',
  label: '변화리더십 101',
  type: 'Methodology',
  domain: 'change_leadership',
  description: '잭 웰치의 변화관리 방법론과 9가지 리더십 자질',
  source_file: '서적 5 - GE의  변화리더십 101.pdf',
  status: 'active',
  tags: ['변화리더십', 'GE', '잭웰치']
});

// Person 노드 (2개)
CREATE (:KnowledgeNode:Person {
  id: 'N005',
  label: '잭웰치',
  type: 'Person',
  domain: 'business_leadership',
  description: 'GE를 세계 최고 기업으로 만든 전설적 CEO',
  status: 'active',
  aliases: ['Jack Welch'],
  tags: ['CEO', '리더십', 'GE']
});

CREATE (:KnowledgeNode:Person {
  id: 'N007',
  label: '심재우',
  type: 'Person',
  domain: 'business_author',
  description: 'GE 글로벌 비즈니스 역량 전문가이자 저술가',
  status: 'active',
  aliases: ['Jai-Woo Shim'],
  tags: ['저자', 'GE전문가', '컨설턴트']
});

// Company 노드 (2개)
CREATE (:KnowledgeNode:Company {
  id: 'N006',
  label: 'GE',
  type: 'Company',
  domain: 'manufacturing',
  description: '세계 최고의 비즈니스 프로세스를 보유한 글로벌 복합기업',
  status: 'active',
  aliases: ['General Electric'],
  tags: ['GE', '글로벌기업', '제조업']
});

CREATE (:KnowledgeNode:Company {
  id: 'N037',
  label: 'Estee Lauder',
  type: 'Company',
  domain: 'cosmetics',
  description: '변화리더십 사례 기업',
  status: 'review',
  aliases: ['에스티로더'],
  tags: ['화장품', '사례', '리더십']
});

// Concept 노드 (13개)
CREATE (:KnowledgeNode:Concept {
  id: 'N004',
  label: '4E + V',
  type: 'Concept',
  domain: 'talent_development',
  description: 'GE의 인재 선발 및 육성 핵심 역량 모델',
  source_file: '서적8-GE는 어떻게 수퍼급 인재를 만드는가.pdf',
  status: 'active',
  aliases: ['4E+V Model'],
  tags: ['인재육성', '역량모델', 'GE']
});

CREATE (:KnowledgeNode:Concept {
  id: 'N008',
  label: '소통의 신',
  type: 'Concept',
  domain: 'communication',
  description: '페이스북 등 소셜미디어를 활용한 현대적 소통 방법론',
  source_file: '소통의신_완결본.pdf',
  status: 'active',
  tags: ['소통', '소셜미디어', '페이스북']
});

CREATE (:KnowledgeNode:Concept {
  id: 'N011',
  label: 'AIDAS의 법칙',
  type: 'Concept',
  domain: 'sales',
  description: '세일즈 프로세스의 5단계 법칙',
  source_file: '서적 4 - GE의 세일즈 노트.pdf',
  status: 'active',
  tags: ['세일즈', '법칙', '프로세스']
});

CREATE (:KnowledgeNode:Concept {
  id: 'N015',
  label: 'Energy',
  type: 'Concept',
  domain: 'talent_development',
  description: '개인의 열정과 추진력 (4E 중 첫 번째)',
  source_file: '서적8-GE는 어떻게 수퍼급 인재를 만드는가.pdf',
  status: 'active',
  aliases: ['에너지'],
  tags: ['4E+V', '역량', '열정']
});

CREATE (:KnowledgeNode:Concept {
  id: 'N016',
  label: 'Energize',
  type: 'Concept',
  domain: 'talent_development',
  description: '타인에게 에너지를 전달하는 능력 (4E 중 두 번째)',
  source_file: '서적8-GE는 어떻게 수퍼급 인재를 만드는가.pdf',
  status: 'active',
  aliases: ['동기부여'],
  tags: ['4E+V', '역량', '동기부여']
});

CREATE (:KnowledgeNode:Concept {
  id: 'N017',
  label: 'Edge',
  type: 'Concept',
  domain: 'talent_development',
  description: '어려운 결정을 내리는 용기 (4E 중 세 번째)',
  source_file: '서적8-GE는 어떻게 수퍼급 인재를 만드는가.pdf',
  status: 'active',
  aliases: ['결단력'],
  tags: ['4E+V', '역량', '결단력']
});

CREATE (:KnowledgeNode:Concept {
  id: 'N018',
  label: 'Execute',
  type: 'Concept',
  domain: 'talent_development',
  description: '계획을 실제 성과로 전환하는 능력 (4E 중 네 번째)',
  source_file: '서적8-GE는 어떻게 수퍼급 인재를 만드는가.pdf',
  status: 'active',
  aliases: ['실행력'],
  tags: ['4E+V', '역량', '실행력']
});

CREATE (:KnowledgeNode:Concept {
  id: 'N019',
  label: 'Values',
  type: 'Concept',
  domain: 'talent_development',
  description: '조직의 핵심 가치 체화 (V)',
  source_file: '서적8-GE는 어떻게 수퍼급 인재를 만드는가.pdf',
  status: 'active',
  aliases: ['가치'],
  tags: ['4E+V', '역량', '가치관']
});

CREATE (:KnowledgeNode:Concept {
  id: 'N023',
  label: 'Threshold of Competency',
  type: 'Concept',
  domain: 'talent_development',
  description: '비즈니스 역량의 역치',
  source_file: '서적 4 - GE의 세일즈 노트.pdf',
  status: 'active',
  aliases: ['역량의 역치'],
  tags: ['역량', '한계', '기준']
});

CREATE (:KnowledgeNode:Concept {
  id: 'N024',
  label: 'Half Time of Competency',
  type: 'Concept',
  domain: 'talent_development',
  description: '역량의 반감기 개념',
  source_file: '서적 4 - GE의 세일즈 노트.pdf',
  status: 'active',
  aliases: ['역량의 반감기'],
  tags: ['역량', '감소', '시간']
});

CREATE (:KnowledgeNode:Concept {
  id: 'N025',
  label: 'YOU&I 회관',
  type: 'Concept',
  domain: 'communication',
  description: '상대방 중심 소통 원칙',
  source_file: '소통의신_완결본.pdf',
  status: 'active',
  aliases: ['YOU and I Principle'],
  tags: ['소통', '상대방중심', '원칙']
});

CREATE (:KnowledgeNode:Concept {
  id: 'N030',
  label: 'Vision Maker',
  type: 'Concept',
  domain: 'leadership',
  description: '미래를 그리는 비전 창조 능력',
  source_file: '서적 5 - GE의  변화리더십 101.pdf',
  status: 'active',
  aliases: ['비전 메이커'],
  tags: ['리더십', '비전', '창조']
});

CREATE (:KnowledgeNode:Concept {
  id: 'N031',
  label: 'Integrity',
  type: 'Concept',
  domain: 'leadership',
  description: '윤리와 신뢰의 리더십',
  source_file: '서적 5 - GE의  변화리더십 101.pdf',
  status: 'active',
  aliases: ['도덕성'],
  tags: ['리더십', '윤리', '신뢰']
});

// Function 노드 (2개)
CREATE (:KnowledgeNode:Function {
  id: 'N009',
  label: 'Boss Managing',
  type: 'Function',
  domain: 'sales',
  description: '상사를 매니징하는 세일즈 기술',
  source_file: '서적 4 - GE의 세일즈 노트.pdf',
  status: 'active',
  aliases: ['보스 매니징'],
  tags: ['세일즈', '매니징', '상사관리']
});

CREATE (:KnowledgeNode:Function {
  id: 'N010',
  label: 'Customer Managing',
  type: 'Function',
  domain: 'sales',
  description: '고객을 매니징하는 세일즈 기술',
  source_file: '서적 4 - GE의 세일즈 노트.pdf',
  status: 'active',
  aliases: ['고객 매니징'],
  tags: ['세일즈', '매니징', '고객관리']
});

// Process 노드 (7개)
CREATE (:KnowledgeNode:Process {
  id: 'N012',
  label: '위크아웃',
  type: 'Process',
  domain: 'change_management',
  description: 'GE의 변화관리 핵심 프로세스',
  source_file: '서적 5 - GE의  변화리더십 101.pdf',
  status: 'active',
  aliases: ['WorkOut'],
  tags: ['변화관리', 'GE', '프로세스']
});

CREATE (:KnowledgeNode:Process {
  id: 'N013',
  label: '액션러닝',
  type: 'Process',
  domain: 'change_management',
  description: 'GE의 실행 중심 학습 방법론',
  source_file: '서적 5 - GE의  변화리더십 101.pdf',
  status: 'active',
  aliases: ['Action Learning'],
  tags: ['학습', '변화관리', 'GE']
});

CREATE (:KnowledgeNode:Process {
  id: 'N020',
  label: 'Executive Program',
  type: 'Process',
  domain: 'talent_development',
  description: 'GE의 경영진 교육 프로그램',
  source_file: '서적8-GE는 어떻게 수퍼급 인재를 만드는가.pdf',
  status: 'active',
  aliases: ['경영진 프로그램'],
  tags: ['교육', 'GE', '경영진']
});

CREATE (:KnowledgeNode:Process {
  id: 'N021',
  label: 'Advanced Manager Program',
  type: 'Process',
  domain: 'talent_development',
  description: 'GE의 고급관리자 교육 프로그램',
  source_file: '서적8-GE는 어떻게 수퍼급 인재를 만드는가.pdf',
  status: 'active',
  aliases: ['고급관리자 프로그램'],
  tags: ['교육', 'GE', '관리자']
});

CREATE (:KnowledgeNode:Process {
  id: 'N022',
  label: 'Professional Skill Program',
  type: 'Process',
  domain: 'talent_development',
  description: 'GE의 전문가 교육 프로그램',
  source_file: '서적8-GE는 어떻게 수퍼급 인재를 만드는가.pdf',
  status: 'active',
  aliases: ['전문가 프로그램'],
  tags: ['교육', 'GE', '전문가']
});

CREATE (:KnowledgeNode:Process {
  id: 'N026',
  label: '타운미팅',
  type: 'Process',
  domain: 'organizational_communication',
  description: '조직 소통 방법론',
  source_file: '서적12-타운미팅(저자교정용)1부_10부.hwp',
  status: 'active',
  aliases: ['Town Meeting'],
  tags: ['조직소통', '회의', '미팅']
});

CREATE (:KnowledgeNode:Process {
  id: 'N027',
  label: 'GE Global 미팅',
  type: 'Process',
  domain: 'business_process',
  description: 'GE의 글로벌 미팅 문화',
  source_file: '서적 4 - GE의 세일즈 노트.pdf',
  status: 'active',
  aliases: ['GE Global Meeting'],
  tags: ['미팅', 'GE', '글로벌']
});

// Framework 노드 (2개)
CREATE (:KnowledgeNode:Framework {
  id: 'N014',
  label: '변화리더십 파이프라인',
  type: 'Framework',
  domain: 'change_leadership',
  description: '체계적인 변화리더 양성 체계',
  source_file: '서적 5 - GE의  변화리더십 101.pdf',
  status: 'active',
  aliases: ['Change Leadership Pipeline'],
  tags: ['리더십', '파이프라인', '변화관리']
});

CREATE (:KnowledgeNode:Framework {
  id: 'N029',
  label: '9가지 핵심 리더십',
  type: 'Framework',
  domain: 'change_leadership',
  description: '잭 웰치의 9가지 변화혁신 리더십 자질',
  source_file: '서적 5 - GE의  변화리더십 101.pdf',
  status: 'active',
  aliases: ['9 Leadership Qualities'],
  tags: ['리더십', '잭웰치', '9가지']
});

// Organization 노드 (1개)
CREATE (:KnowledgeNode:Organization {
  id: 'N038',
  label: 'BBC',
  type: 'Organization',
  domain: 'business_writers',
  description: 'Biz Book Writers Club - 비즈니스 저술가 클럽',
  status: 'active',
  aliases: ['Biz Book Writers Club'],
  tags: ['저술', '클럽', '비즈니스']
});

// 나머지 Concept 노드들 (간략화)
CREATE (:KnowledgeNode:Concept {id: 'N032', label: 'Communication', type: 'Concept', domain: 'leadership', status: 'active'});
CREATE (:KnowledgeNode:Concept {id: 'N033', label: 'Risk-Taking', type: 'Concept', domain: 'leadership', status: 'active'});
CREATE (:KnowledgeNode:Concept {id: 'N034', label: 'Sharing & Celebration', type: 'Concept', domain: 'leadership', status: 'active'});
CREATE (:KnowledgeNode:Concept {id: 'N035', label: 'Excellence & Competency', type: 'Concept', domain: 'leadership', status: 'active'});
CREATE (:KnowledgeNode:Concept {id: 'N036', label: '1% 위대한 기업', type: 'Concept', domain: 'organizational_innovation', status: 'active'});
CREATE (:KnowledgeNode:Process {id: 'N028', label: '10 Steps of Sales Process', type: 'Process', domain: 'sales', status: 'active'});

// 4단계: 관계 생성 (50개)

// includes 관계
MATCH (a:KnowledgeNode {id: 'N001'}), (b:KnowledgeNode {id: 'N002'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N001'}), (b:KnowledgeNode {id: 'N003'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N001'}), (b:KnowledgeNode {id: 'N004'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N002'}), (b:KnowledgeNode {id: 'N009'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.92}]->(b);

MATCH (a:KnowledgeNode {id: 'N002'}), (b:KnowledgeNode {id: 'N010'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.92}]->(b);

MATCH (a:KnowledgeNode {id: 'N002'}), (b:KnowledgeNode {id: 'N011'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.90}]->(b);

MATCH (a:KnowledgeNode {id: 'N002'}), (b:KnowledgeNode {id: 'N028'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.90}]->(b);

MATCH (a:KnowledgeNode {id: 'N003'}), (b:KnowledgeNode {id: 'N012'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.93}]->(b);

MATCH (a:KnowledgeNode {id: 'N003'}), (b:KnowledgeNode {id: 'N013'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.93}]->(b);

MATCH (a:KnowledgeNode {id: 'N003'}), (b:KnowledgeNode {id: 'N014'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.92}]->(b);

MATCH (a:KnowledgeNode {id: 'N003'}), (b:KnowledgeNode {id: 'N029'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N008'}), (b:KnowledgeNode {id: 'N025'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.90}]->(b);

// 9가지 리더십 → 하위 요소
MATCH (a:KnowledgeNode {id: 'N029'}), (b:KnowledgeNode {id: 'N015'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N029'}), (b:KnowledgeNode {id: 'N016'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N029'}), (b:KnowledgeNode {id: 'N030'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N029'}), (b:KnowledgeNode {id: 'N017'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N029'}), (b:KnowledgeNode {id: 'N018'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N029'}), (b:KnowledgeNode {id: 'N031'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N029'}), (b:KnowledgeNode {id: 'N032'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N029'}), (b:KnowledgeNode {id: 'N033'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N029'}), (b:KnowledgeNode {id: 'N034'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N029'}), (b:KnowledgeNode {id: 'N035'})
CREATE (a)-[:INCLUDES {relation: 'includes', confidence: 0.95}]->(b);

// part_of 관계 (4E+V)
MATCH (a:KnowledgeNode {id: 'N004'}), (b:KnowledgeNode {id: 'N015'})
CREATE (a)-[:PART_OF {relation: 'part_of', confidence: 0.98}]->(b);

MATCH (a:KnowledgeNode {id: 'N004'}), (b:KnowledgeNode {id: 'N016'})
CREATE (a)-[:PART_OF {relation: 'part_of', confidence: 0.98}]->(b);

MATCH (a:KnowledgeNode {id: 'N004'}), (b:KnowledgeNode {id: 'N017'})
CREATE (a)-[:PART_OF {relation: 'part_of', confidence: 0.98}]->(b);

MATCH (a:KnowledgeNode {id: 'N004'}), (b:KnowledgeNode {id: 'N018'})
CREATE (a)-[:PART_OF {relation: 'part_of', confidence: 0.98}]->(b);

MATCH (a:KnowledgeNode {id: 'N004'}), (b:KnowledgeNode {id: 'N019'})
CREATE (a)-[:PART_OF {relation: 'part_of', confidence: 0.98}]->(b);

// created 관계
MATCH (a:KnowledgeNode {id: 'N005'}), (b:KnowledgeNode {id: 'N003'})
CREATE (a)-[:CREATED {relation: 'created', confidence: 0.98}]->(b);

MATCH (a:KnowledgeNode {id: 'N005'}), (b:KnowledgeNode {id: 'N029'})
CREATE (a)-[:CREATED {relation: 'created', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N007'}), (b:KnowledgeNode {id: 'N001'})
CREATE (a)-[:CREATED {relation: 'created', confidence: 0.92}]->(b);

MATCH (a:KnowledgeNode {id: 'N007'}), (b:KnowledgeNode {id: 'N008'})
CREATE (a)-[:CREATED {relation: 'created', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N007'}), (b:KnowledgeNode {id: 'N026'})
CREATE (a)-[:CREATED {relation: 'created', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N007'}), (b:KnowledgeNode {id: 'N036'})
CREATE (a)-[:CREATED {relation: 'created', confidence: 0.95}]->(b);

// leads, produces, worked_at, member_of 관계
MATCH (a:KnowledgeNode {id: 'N005'}), (b:KnowledgeNode {id: 'N006'})
CREATE (a)-[:LEADS {relation: 'leads', confidence: 0.98}]->(b);

MATCH (a:KnowledgeNode {id: 'N006'}), (b:KnowledgeNode {id: 'N001'})
CREATE (a)-[:PRODUCES {relation: 'produces', confidence: 0.95}]->(b);

MATCH (a:KnowledgeNode {id: 'N007'}), (b:KnowledgeNode {id: 'N006'})
CREATE (a)-[:WORKED_AT {relation: 'worked_at', confidence: 0.98}]->(b);

MATCH (a:KnowledgeNode {id: 'N007'}), (b:KnowledgeNode {id: 'N038'})
CREATE (a)-[:MEMBER_OF {relation: 'member_of', confidence: 0.95}]->(b);

// uses 관계 (GE → 교육 프로그램)
MATCH (a:KnowledgeNode {id: 'N006'}), (b:KnowledgeNode {id: 'N020'})
CREATE (a)-[:USES {relation: 'uses', confidence: 0.93}]->(b);

MATCH (a:KnowledgeNode {id: 'N006'}), (b:KnowledgeNode {id: 'N021'})
CREATE (a)-[:USES {relation: 'uses', confidence: 0.93}]->(b);

MATCH (a:KnowledgeNode {id: 'N006'}), (b:KnowledgeNode {id: 'N022'})
CREATE (a)-[:USES {relation: 'uses', confidence: 0.93}]->(b);

MATCH (a:KnowledgeNode {id: 'N006'}), (b:KnowledgeNode {id: 'N027'})
CREATE (a)-[:USES {relation: 'uses', confidence: 0.92}]->(b);

// 5단계: 인덱스 생성 (성능 최적화)
CREATE INDEX node_type IF NOT EXISTS FOR (n:KnowledgeNode) ON (n.type);
CREATE INDEX node_domain IF NOT EXISTS FOR (n:KnowledgeNode) ON (n.domain);
CREATE INDEX node_status IF NOT EXISTS FOR (n:KnowledgeNode) ON (n.status);

// 6단계: 검증 쿼리
// 전체 노드 수 확인
MATCH (n:KnowledgeNode) RETURN count(n) as total_nodes;

// 전체 관계 수 확인
MATCH ()-[r]->() RETURN count(r) as total_relationships;

// 유형별 노드 수
MATCH (n:KnowledgeNode) RETURN n.type as type, count(n) as count ORDER BY count DESC;

// 관계 유형별 통계
MATCH ()-[r]->() RETURN type(r) as relationship_type, count(r) as count ORDER BY count DESC;

// 연결이 가장 많은 노드 Top 10
MATCH (n:KnowledgeNode)
RETURN n.label as node,
       n.type as type,
       size((n)-[]-()) as connections
ORDER BY connections DESC
LIMIT 10;

// ============================================================
// Import 완료!
// Neo4j Browser에서 다음 쿼리로 그래프 시각화:
// MATCH (n)-[r]->(m) RETURN n, r, m LIMIT 100
// ============================================================
