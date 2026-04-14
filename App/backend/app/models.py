from sqlalchemy import Column, String, Boolean, DateTime, Float, ForeignKey, TEXT, Integer, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID, TSVECTOR
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from geoalchemy2 import Geometry
import uuid
from .database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    full_name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    location = Column(Geometry('POINT', srid=4326), nullable=True)
    is_active = Column(Boolean, default=True)
    role = Column(String, default="user") # 'user' or 'admin'
    last_password_change = Column(DateTime(timezone=True), server_default=func.now())
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    interests = relationship("UserInterest", back_populates="user", cascade="all, delete-orphan")
    recommendations = relationship("Recommendation", back_populates="user", cascade="all, delete-orphan")
    interactions = relationship("UserEventInteraction", back_populates="user", cascade="all, delete-orphan")


class UserInterest(Base):
    __tablename__ = "user_interests"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    interest = Column(String, nullable=False)

    __table_args__ = (
        UniqueConstraint('user_id', 'interest', name='uix_user_interest'),
    )

    # Relationships
    user = relationship("User", back_populates="interests")


class ScrapedSource(Base):
    __tablename__ = "scraped_sources"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    source_name = Column(String, nullable=False)
    url = Column(String, unique=True, nullable=False)
    is_active = Column(Boolean, default=True)
    scrape_interval_hours = Column(Integer, default=24)
    last_scraped_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    events = relationship("Event", back_populates="source")


class Event(Base):
    __tablename__ = "events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    title = Column(String, nullable=False)
    description = Column(TEXT, nullable=True)
    start_date = Column(DateTime(timezone=True), nullable=False)
    end_date = Column(DateTime(timezone=True), nullable=True)
    location_name = Column(String, nullable=True)
    location = Column(Geometry('POINT', srid=4326), nullable=True)
    category = Column(String, nullable=False)
    event_url = Column(String, nullable=True)
    source_id = Column(UUID(as_uuid=True), ForeignKey("scraped_sources.id", ondelete="SET NULL"), nullable=True)
    status = Column(String, default="active") # active, archived, deleted
    search_vector = Column(TSVECTOR, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        UniqueConstraint('source_id', 'event_url', name='uix_event_source_url'),
    )

    # Relationships
    source = relationship("ScrapedSource", back_populates="events")
    recommendations = relationship("Recommendation", back_populates="event", cascade="all, delete-orphan")
    interactions = relationship("UserEventInteraction", back_populates="event", cascade="all, delete-orphan")


class Recommendation(Base):
    __tablename__ = "recommendations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    event_id = Column(UUID(as_uuid=True), ForeignKey("events.id", ondelete="CASCADE"), nullable=False)
    score = Column(Float, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        UniqueConstraint('user_id', 'event_id', name='uix_user_event_recommendation'),
    )

    # Relationships
    user = relationship("User", back_populates="recommendations")
    event = relationship("Event", back_populates="recommendations")


class UserEventInteraction(Base):
    __tablename__ = "user_event_interactions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    event_id = Column(UUID(as_uuid=True), ForeignKey("events.id", ondelete="CASCADE"), nullable=False)
    interaction_type = Column(String, nullable=False) # view, click, rsvp, dismiss
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    user = relationship("User", back_populates="interactions")
    event = relationship("Event", back_populates="interactions")
