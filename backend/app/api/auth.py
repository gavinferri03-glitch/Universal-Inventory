
import uuid

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.models.user import User
from app.models.organization import Organization
from app.models.membership import OrganizationMember
from app.schemas.auth import RegisterRequest, LoginRequest, AuthResponse
from app.core.security import hash_password, verify_password
from app.core.tokens import create_access_token

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=AuthResponse)
def register(data: RegisterRequest, db: Session = Depends(get_db)):
    email = data.email.strip().lower()

    existing_user = db.scalar(
        select(User).where(User.email == email)
    )

    if existing_user:
        raise HTTPException(
            status_code=409,
            detail="Email already registered"
        )

    organization = Organization(
        name=data.organization_name.strip(),
        slug=f"org-{uuid.uuid4().hex[:12]}"
    )

    user = User(
        email=email,
        hashed_password=hash_password(data.password)
    )

    db.add_all([organization, user])
    db.flush()

    membership = OrganizationMember(
        organization_id=organization.id,
        user_id=user.id,
        role="owner"
    )

    db.add(membership)
    db.commit()

    return AuthResponse(
        access_token=create_access_token(user.id),
        user_id=user.id,
        organization_id=organization.id
    )


@router.post("/login", response_model=AuthResponse)
def login(data: LoginRequest, db: Session = Depends(get_db)):
    email = data.email.strip().lower()

    user = db.scalar(
        select(User).where(User.email == email)
    )

    if not user or not verify_password(
        data.password,
        user.hashed_password
    ):
        raise HTTPException(
            status_code=401,
            detail="Invalid email or password"
        )

    membership = db.scalar(
        select(OrganizationMember)
        .where(OrganizationMember.user_id == user.id)
        .order_by(OrganizationMember.created_at)
    )

    if not membership:
        raise HTTPException(
            status_code=403,
            detail="No organization membership found"
        )

    return AuthResponse(
        access_token=create_access_token(user.id),
        user_id=user.id,
        organization_id=membership.organization_id
    )
