import { Search, SlidersHorizontal, Sparkles, MapPin, Calendar, Users, Plus } from 'lucide-react';
import { Link } from 'react-router';
import { mockEvents } from '../data/mockData';
import { motion } from 'motion/react';

export function DiscoveryFeed() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-orange-50/40 to-amber-50/40 pb-24" style={{ backgroundColor: 'var(--bg-cream)' }}>
      {/* Header */}
      <div className="bg-white/70 backdrop-blur-xl border-b border-gray-200/50 sticky top-0 z-10">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center justify-between mb-4">
            <div>
              <h1 className="text-2xl font-semibold bg-gradient-to-r from-[var(--neighborhood-green)] to-[var(--electric-blue)] bg-clip-text text-transparent">
                Mahalle-Connect
              </h1>
              <p className="text-sm text-gray-600">Discover local events</p>
            </div>
          </div>
          
          {/* Search Bar */}
          <div className="flex gap-2">
            <div className="flex-1 relative">
              <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
              <input
                type="text"
                placeholder="Search events, locations..."
                className="w-full pl-10 pr-4 py-2.5 rounded-2xl bg-gray-100/80 border border-gray-200/50 focus:outline-none focus:ring-2 focus:ring-[var(--electric-blue)]/30"
              />
            </div>
            <button className="p-2.5 rounded-2xl bg-gradient-to-br from-[var(--neighborhood-green)] to-[var(--electric-blue)] text-white">
              <SlidersHorizontal className="w-5 h-5" />
            </button>
          </div>
        </div>
      </div>

      {/* Create Event Button */}
      <div className="max-w-md mx-auto px-4 pt-4">
        <Link to="/create-event">
          <motion.button
            initial={{ opacity: 0, y: 10 }}
            animate={{ opacity: 1, y: 0 }}
            className="w-full p-4 rounded-3xl bg-gradient-to-r from-[var(--primary-orange)] to-[var(--dark-orange)] text-white shadow-lg hover:shadow-xl transition-all flex items-center justify-center gap-3"
          >
            <Plus className="w-5 h-5" />
            <span className="font-semibold">Create Event</span>
          </motion.button>
        </Link>
      </div>

      {/* Event Cards */}
      <div className="max-w-md mx-auto px-4 pt-4 space-y-4">
        {mockEvents.map((event, index) => (
          <motion.div
            key={event.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: index * 0.1 }}
          >
            <Link to={`/event/${event.id}`}>
              <div className="bg-white/80 backdrop-blur-sm rounded-3xl overflow-hidden border border-gray-200/50 shadow-sm hover:shadow-md transition-all">
                {/* Event Image */}
                <div className="relative h-48 overflow-hidden">
                  <img
                    src={event.imageUrl}
                    alt={event.title}
                    className="w-full h-full object-cover"
                  />
                  <div className="absolute top-3 right-3 px-3 py-1.5 rounded-full bg-white/90 backdrop-blur-sm text-xs font-semibold flex items-center gap-1">
                    <Sparkles className="w-3 h-3 text-[var(--electric-blue)]" />
                    {event.aiScore}% Match
                  </div>
                  <div className="absolute top-3 left-3 px-3 py-1.5 rounded-full bg-[var(--neighborhood-green)] text-white text-xs font-semibold capitalize">
                    {event.category}
                  </div>
                </div>

                {/* Event Details */}
                <div className="p-4">
                  <h3 className="font-semibold text-gray-900 mb-2 line-clamp-2">
                    {event.title}
                  </h3>
                  
                  <div className="space-y-2 mb-3">
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Calendar className="w-4 h-4 text-[var(--electric-blue)]" />
                      <span>{event.date} • {event.time}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <MapPin className="w-4 h-4 text-[var(--neighborhood-green)]" />
                      <span>{event.location} • {event.distance}</span>
                    </div>
                    <div className="flex items-center gap-2 text-sm text-gray-600">
                      <Users className="w-4 h-4 text-gray-400" />
                      <span>{event.attendees} attending</span>
                    </div>
                  </div>

                  {/* AI Summary */}
                  <div className="p-3 rounded-2xl bg-gradient-to-br from-[var(--electric-blue)]/5 to-[var(--neighborhood-green)]/5 border border-[var(--electric-blue)]/10">
                    <p className="text-xs text-gray-700 italic">
                      {event.aiSummary}
                    </p>
                  </div>
                </div>
              </div>
            </Link>
          </motion.div>
        ))}
      </div>
    </div>
  );
}