from sqlalchemy import Column, String, Boolean, DateTime, Float, ForeignKey, TEXT, Integer, UniqueConstraint, Enum, Index
from sqlalchemy.dialects.postgresql import UUID, TSVECTOR
from sqlalchemy.sql import func
from sqlalchemy.orm import relationship
from geoalchemy2 import Geometry
import uuid
from database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    username = Column(String(50), unique=True, index=True, nullable=True) # Added for social mechanics
    full_name = Column(String(150), nullable=False)
    email = Column(String(255), unique=True, index=True, nullable=False)
    profile_picture_url = Column(String(1024), nullable=True) 
    hashed_password = Column(String(255), nullable=True) # Nullable for OAuth platforms
    location = Column(Geometry('POINT', srid=4326), nullable=True)
    is_active = Column(Boolean, default=True)
    
    # Soft delete and Auth specifics
    is_deleted = Column(Boolean, default=False)
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    role = Column(Enum('user', 'moderator', 'admin', name='user_roles'), default="user", nullable=False)
    
    # Brute Force Protection
    failed_login_attempts = Column(Integer, default=0)
    locked_until = Column(DateTime(timezone=True), nullable=True)
    
    # Token / Device Auth
    token_version = Column(Integer, default=1)
    
    last_password_change = Column(DateTime(timezone=True), server_default=func.now())
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        Index('idx_user_location', 'location', postgresql_using='gist'),
    )

    # Relationships
    interests = relationship("UserInterest", back_populates="user", cascade="all, delete-orphan")
    recommendations = relationship("Recommendation", back_populates="user", cascade="all, delete-orphan")
    logs = relationship("EventLog", back_populates="user", cascade="all, delete-orphan")
    rsvps = relationship("EventRSVP", back_populates="user", cascade="all, delete-orphan")
    devices = relationship("UserDevice", back_populates="user", cascade="all, delete-orphan")
    followers = relationship("UserConnection", foreign_keys="[UserConnection.followed_id]", back_populates="followed", cascade="all, delete-orphan")
    following = relationship("UserConnection", foreign_keys="[UserConnection.follower_id]", back_populates="follower", cascade="all, delete-orphan")
    created_events = relationship("Event", back_populates="creator", cascade="all, delete-orphan")


class UserConnection(Base):
    """
    Social Network component for following/friending neighbors
    """
    __tablename__ = "user_connections"

    follower_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    followed_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), primary_key=True)
    status = Column(Enum('pending', 'accepted', 'blocked', name='connection_status'), default='accepted', nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    follower = relationship("User", foreign_keys=[follower_id], back_populates="following")
    followed = relationship("User", foreign_keys=[followed_id], back_populates="followers")


class UserDevice(Base):
    """
    Table for storing Push Notification Tokens (FCM/APNS) for users
    """
    __tablename__ = "user_devices"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    fcm_token = Column(String(512), unique=True, nullable=False)
    device_type = Column(String(50), nullable=True) # iOS, Android, Web
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    
    # Relationships
    user = relationship("User", back_populates="devices")


class UserInterest(Base):
    __tablename__ = "user_interests"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    interest = Column(String(100), nullable=False)

    __table_args__ = (
        UniqueConstraint('user_id', 'interest', name='uix_user_interest'),
    )

    # Relationships
    user = relationship("User", back_populates="interests")


class ScrapedSource(Base):
    __tablename__ = "scraped_sources"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    source_name = Column(String(150), nullable=False)
    url = Column(String(512), unique=True, nullable=False)
    is_active = Column(Boolean, default=True)
    scrape_interval_hours = Column(Integer, default=24)
    last_scraped_at = Column(DateTime(timezone=True), nullable=True)
    
    # Scraper Health Monitoring
    last_scrape_status = Column(Enum('success', 'failed', 'pending', name='scrape_status'), nullable=True)
    last_scrape_error = Column(TEXT, nullable=True)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    events = relationship("Event", back_populates="source")


class Event(Base):
    __tablename__ = "events"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    creator_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    source_id = Column(UUID(as_uuid=True), ForeignKey("scraped_sources.id", ondelete="SET NULL"), nullable=True, index=True)
    
    title = Column(String(255), nullable=False)
    description = Column(TEXT, nullable=True)
    
    # Visual and Commercial Properties
    image_url = Column(String(1024), nullable=True)
    is_free = Column(Boolean, default=True)
    
    start_date = Column(DateTime(timezone=True), nullable=False, index=True)
    end_date = Column(DateTime(timezone=True), nullable=True)
    
    location_name = Column(String(255), nullable=True)
    location = Column(Geometry('POINT', srid=4326), nullable=True)
    
    category = Column(String(100), nullable=False, index=True)
    event_url = Column(String(1024), nullable=True)
    
    status = Column(Enum('active', 'archived', 'deleted', name='event_status'), default="active", nullable=False) 
    
    # Soft deletion
    is_deleted = Column(Boolean, default=False)
    deleted_at = Column(DateTime(timezone=True), nullable=True)
    
    search_vector = Column(TSVECTOR, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        UniqueConstraint('source_id', 'event_url', name='uix_event_source_url'),
        Index('idx_event_location', 'location', postgresql_using='gist'),
        Index('idx_event_search_vector', 'search_vector', postgresql_using='gin'),
    )

    # Relationships
    source = relationship("ScrapedSource", back_populates="events")
    creator = relationship("User", back_populates="created_events")
    recommendations = relationship("Recommendation", back_populates="event", cascade="all, delete-orphan")
    logs = relationship("EventLog", back_populates="event", cascade="all, delete-orphan")
    rsvps = relationship("EventRSVP", back_populates="event", cascade="all, delete-orphan")


class Recommendation(Base):
    __tablename__ = "recommendations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    event_id = Column(UUID(as_uuid=True), ForeignKey("events.id", ondelete="SET NULL"), nullable=True, index=True) # SET NULL allows keeping history
    
    score = Column(Float, nullable=False)
    model_version = Column(String(50), nullable=True) # Keeps track of which AI model gave the score
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        UniqueConstraint('user_id', 'event_id', name='uix_user_event_recommendation'),
    )

    # Relationships
    user = relationship("User", back_populates="recommendations")
    event = relationship("Event", back_populates="recommendations")


class EventLog(Base):
    """
    Log table for AI extraction metrics and tracking purposes. 
    Not unique per user-event on purpose (To record multiple views/clicks over time)
    """
    __tablename__ = "event_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="SET NULL"), nullable=True, index=True)
    event_id = Column(UUID(as_uuid=True), ForeignKey("events.id", ondelete="SET NULL"), nullable=True, index=True)
    
    action = Column(Enum('view', 'click', 'dismiss', name='event_action_type'), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    # Relationships
    user = relationship("User", back_populates="logs")
    event = relationship("Event", back_populates="logs")


class EventRSVP(Base):
    """
    State table tracking User's active decision about an event
    """
    __tablename__ = "event_rsvps"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, index=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    event_id = Column(UUID(as_uuid=True), ForeignKey("events.id", ondelete="CASCADE"), nullable=False, index=True)
    
    status = Column(Enum('attending', 'interested', 'declined', name='rsvp_status'), nullable=False)
    
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    __table_args__ = (
        UniqueConstraint('user_id', 'event_id', name='uix_user_event_rsvp'),
    )

    # Relationships
    user = relationship("User", back_populates="rsvps")
    event = relationship("Event", back_populates="rsvps")
