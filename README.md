# OwnMyTodo AI

모호한 할 일을 구체적으로 변환해주는 AI API 서버입니다.

> "운동" → "저녁 7시 러닝 30분 하기"

## 기능

- Gemini AI를 활용한 할 일 재작성
- Rate Limiting (IP당 분당 10회)
- CORS 지원 (Flutter 앱 등 연동 가능)

## 세팅 방법

### 1. 저장소 클론

```bash
git clone <repository-url>
cd ownmytodo-ai
```

### 2. 가상환경 생성 및 활성화

```bash
python -m venv .venv
source .venv/bin/activate  # macOS/Linux
# .venv\Scripts\activate  # Windows
```

### 3. 의존성 설치

```bash
pip install -r requirements.txt
```

### 4. 환경 변수 설정

`.env.example`을 복사해서 `.env` 파일을 만들고, Gemini API 키를 입력합니다.

```bash
cp .env.example .env
```

`.env` 파일 내용:
```
GEMINI_API_KEY=your_gemini_api_key_here
```

Gemini API 키는 [Google AI Studio](https://aistudio.google.com/app/apikey)에서 발급받을 수 있습니다.

### 5. 서버 실행

```bash
uvicorn main:app --reload
```

서버가 `http://localhost:8000`에서 실행됩니다.

## API 사용법

### 할 일 재작성

**POST** `/rewrite`

```bash
curl -X POST "http://localhost:8000/rewrite" \
  -H "Content-Type: application/json" \
  -d '{"title": "운동", "context": "오늘 저녁 약속 있음"}'
```

**Request Body:**
```json
{
  "title": "운동",
  "context": "오늘 저녁 약속 있음"  // 선택 사항
}
```

**Response:**
```json
{
  "rewritten": "아침 6시 러닝 30분 하기"
}
```

### 헬스 체크

**GET** `/health`

```bash
curl http://localhost:8000/health
```

**Response:**
```json
{
  "status": "ok"
}
```

## API 문서

서버 실행 후 아래 주소에서 Swagger UI를 확인할 수 있습니다:

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## 기술 스택

- **FastAPI** - 웹 프레임워크
- **Gemini 2.5 Flash** - AI 모델
- **SlowAPI** - Rate Limiting
- **Pydantic** - 데이터 검증
- **Uvicorn** - ASGI 서버

## 프로젝트 구조

```
ownmytodo-ai/
├── main.py           # FastAPI 앱 및 엔드포인트
├── prompts.py        # AI 프롬프트 템플릿
├── requirements.txt  # Python 의존성
├── .env.example      # 환경 변수 예시
└── .gitignore
```
