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
    browsing_logs = relationship("EventBrowsingLog", back_populates="user", cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")


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
    browsing_logs = relationship("EventBrowsingLog", back_populates="event", cascade="all, delete-orphan")


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


class EventBrowsingLog(Base):
    """Kullanıcıların etkinlik gezinme/tıklama logları.
    Hangi kullanıcı hangi etkinliğe tıkladı, hangi ekrandan geldi bilgisini tutar.
    Bu veriler üzerinden bölgesel/kategorik ilgi analizi yapılır.
    """
    __tablename__ = "event_browsing_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    event_id = Column(UUID(as_uuid=True), ForeignKey("events.id", ondelete="CASCADE"), nullable=False, index=True)

    # Gezinme detayları
    action = Column(String, nullable=False)  # 'click_card', 'click_detail', 'click_map_marker'
    event_category = Column(String, nullable=False, index=True)  # Denormalize — hızlı analitik sorgu
    event_location_name = Column(String, nullable=True)  # Denormalize — konum adı

    # Bağlam
    source_screen = Column(String, nullable=True)  # 'discovery_feed', 'map_view', 'ai_picks', 'search'

    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    # Relationships
    user = relationship("User", back_populates="browsing_logs")
    event = relationship("Event", back_populates="browsing_logs")


class Notification(Base):
    """AI tarafından üretilen uygulama içi bildirimler.
    Kullanıcının gezinme loglarına dayanarak kişiselleştirilmiş öneriler sunar.
    Günde 1 kez üretilir.
    """
    __tablename__ = "notifications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    title = Column(String, nullable=False)
    body = Column(TEXT, nullable=False)
    notification_type = Column(String, nullable=False)  # 'event_suggestion', 'trend_alert', 'create_event_prompt'
    related_category = Column(String, nullable=True)
    related_district = Column(String, nullable=True)
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)

    # Relationships
    user = relationship("User", back_populates="notifications")


class DistrictTrend(Base):
    """Bölge bazlı etkinlik kategorisi trend verileri.
    Belediye önerisi ve yönetim paneli için kullanılır.
    Periyodik olarak (günlük/haftalık) hesaplanır.
    """
    __tablename__ = "district_trends"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    district = Column(String, nullable=False, index=True)
    category = Column(String, nullable=False, index=True)
    total_views = Column(Integer, default=0)
    unique_viewers = Column(Integer, default=0)
    trend_score = Column(Float, nullable=False)  # Hesaplanan popülerlik skoru
    period_start = Column(DateTime(timezone=True), nullable=False)
    period_end = Column(DateTime(timezone=True), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    __table_args__ = (
        UniqueConstraint('district', 'category', 'period_start', name='uix_district_category_period'),
    )

