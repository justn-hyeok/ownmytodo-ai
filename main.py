from fastapi import FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from slowapi import Limiter, _rate_limit_exceeded_handler
from slowapi.util import get_remote_address
from slowapi.errors import RateLimitExceeded
import google.generativeai as genai
from dotenv import load_dotenv
import os

from prompts import REWRITE_PROMPT
from datetime import datetime

# 환경 변수 로드
load_dotenv()

# Gemini API 설정
api_key = os.getenv("GEMINI_API_KEY")
if api_key:
    genai.configure(api_key=api_key)

# Rate Limiter 설정 (IP 기반)
limiter = Limiter(key_func=get_remote_address)


# Pydantic 모델
class RewriteRequest(BaseModel):
    title: str
    today_todos: str | None = None
    user_context: str | None = None


class RewriteResponse(BaseModel):
    rewritten: str


# FastAPI 앱 생성
app = FastAPI(
    title="OwnMyTodo AI",
    description="모호한 할 일을 구체적으로 변환하는 AI 서버",
    version="1.0.0",
)

# Rate Limiter 등록
app.state.limiter = limiter
app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

# CORS 설정 (Flutter 앱에서 호출 허용)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Gemini 모델 초기화
model = genai.GenerativeModel("gemini-2.5-flash")


@app.post("/rewrite", response_model=RewriteResponse)
@limiter.limit("10/minute")
async def rewrite_todo(request: Request, body: RewriteRequest):
    """모호한 할 일을 구체적으로 재작성합니다. (분당 10회 제한)"""

    if not api_key:
        raise HTTPException(
            status_code=500,
            detail="서버 설정 오류: GEMINI_API_KEY가 설정되지 않았습니다.",
        )

    # 프롬프트 생성
    today_todos = body.today_todos if body.today_todos else "없음"
    user_context = body.user_context if body.user_context else "없음"
    current_time = datetime.now().strftime("%H:%M")

    prompt = REWRITE_PROMPT.format(
        title=body.title,
        today_todos=today_todos,
        current_time=current_time,
        user_context=user_context,
    )

    try:
        # Gemini API 비동기 호출
        response = await model.generate_content_async(prompt)
        rewritten = response.text.strip()

        return RewriteResponse(rewritten=rewritten)

    except Exception as e:
        raise HTTPException(
            status_code=502,
            detail=f"AI 서비스 호출 실패: {str(e)}",
        )


@app.get("/health")
async def health_check():
    """서버 상태 확인"""
    return {"status": "ok"}
