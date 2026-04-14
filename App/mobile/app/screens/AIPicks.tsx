import { Sparkles, TrendingUp, Calendar, MapPin } from 'lucide-react';
import { Link } from 'react-router';
import { mockEvents } from '../data/mockData';
import { motion } from 'motion/react';

export function AIPicks() {
  // Sort events by AI score
  const topPicks = [...mockEvents].sort((a, b) => b.aiScore - a.aiScore).slice(0, 3);
  const trendingEvents = mockEvents.filter(e => e.attendees > 50);

  return (
    <div className="min-h-screen bg-gradient-to-b from-orange-50/40 to-amber-50/40 pb-24" style={{ backgroundColor: 'var(--bg-cream)' }}>
      {/* Header */}
      <div className="bg-white/70 backdrop-blur-xl border-b border-gray-200/50">
        <div className="max-w-md mx-auto px-4 py-6">
          <div className="text-center">
            <div className="inline-flex items-center justify-center w-16 h-16 rounded-full bg-gradient-to-br from-[var(--neighborhood-green)] to-[var(--electric-blue)] mb-4">
              <Sparkles className="w-8 h-8 text-white" />
            </div>
            <h1 className="text-2xl font-semibold text-gray-900 mb-2">
              AI-Powered Picks
            </h1>
            <p className="text-sm text-gray-600">
              Events curated specifically for you
            </p>
          </div>
        </div>
      </div>

      <div className="max-w-md mx-auto px-4 py-6 space-y-6">
        {/* Top Matches */}
        <section>
          <div className="flex items-center gap-2 mb-4">
            <Sparkles className="w-5 h-5 text-[var(--electric-blue)]" />
            <h2 className="font-semibold text-gray-900">Top Matches For You</h2>
          </div>

          <div className="space-y-3">
            {topPicks.map((event, index) => (
              <motion.div
                key={event.id}
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                transition={{ delay: index * 0.1 }}
              >
                <Link to={`/event/${event.id}`}>
                  <div className="bg-white/80 backdrop-blur-sm rounded-3xl overflow-hidden border border-gray-200/50 shadow-sm hover:shadow-md transition-all">
                    <div className="flex gap-4 p-4">
                      {/* Event Image */}
                      <div className="relative w-24 h-24 rounded-2xl overflow-hidden flex-shrink-0">
                        <img
                          src={event.imageUrl}
                          alt={event.title}
                          className="w-full h-full object-cover"
                        />
                        <div className="absolute top-2 right-2 w-8 h-8 rounded-full bg-white/90 backdrop-blur-sm flex items-center justify-center">
                          <span className="text-xs font-bold text-[var(--electric-blue)]">
                            {event.aiScore}
                          </span>
                        </div>
                      </div>

                      {/* Event Info */}
                      <div className="flex-1 min-w-0">
                        <h3 className="font-semibold text-gray-900 mb-1 line-clamp-1">
                          {event.title}
                        </h3>
                        <div className="flex items-center gap-1 text-xs text-gray-600 mb-1">
                          <Calendar className="w-3 h-3" />
                          <span>{event.date}</span>
                        </div>
                        <div className="flex items-center gap-1 text-xs text-gray-600">
                          <MapPin className="w-3 h-3 text-[var(--neighborhood-green)]" />
                          <span>{event.distance}</span>
                        </div>
                      </div>

                      {/* Rank Badge */}
                      <div className="flex items-center">
                        <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-[var(--neighborhood-green)] to-[var(--electric-blue)] text-white flex items-center justify-center font-bold">
                          #{index + 1}
                        </div>
                      </div>
                    </div>
                  </div>
                </Link>
              </motion.div>
            ))}
          </div>
        </section>

        {/* Trending in Your Area */}
        <section>
          <div className="flex items-center gap-2 mb-4">
            <TrendingUp className="w-5 h-5 text-[var(--neighborhood-green)]" />
            <h2 className="font-semibold text-gray-900">Trending in Your Area</h2>
          </div>

          <div className="grid grid-cols-2 gap-3">
            {trendingEvents.map((event, index) => (
              <motion.div
                key={event.id}
                initial={{ opacity: 0, scale: 0.9 }}
                animate={{ opacity: 1, scale: 1 }}
                transition={{ delay: 0.3 + index * 0.1 }}
              >
                <Link to={`/event/${event.id}`}>
                  <div className="bg-white/80 backdrop-blur-sm rounded-2xl overflow-hidden border border-gray-200/50 shadow-sm hover:shadow-md transition-all">
                    <div className="relative h-32">
                      <img
                        src={event.imageUrl}
                        alt={event.title}
                        className="w-full h-full object-cover"
                      />
                      <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent"></div>
                      <div className="absolute bottom-2 left-2 right-2">
                        <h4 className="text-white font-semibold text-sm line-clamp-2">
                          {event.title}
                        </h4>
                      </div>
                      <div className="absolute top-2 right-2 px-2 py-1 rounded-full bg-white/90 backdrop-blur-sm text-xs font-semibold">
                        🔥 {event.attendees}
                      </div>
                    </div>
                  </div>
                </Link>
              </motion.div>
            ))}
          </div>
        </section>

        {/* AI Insights */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.8 }}
          className="bg-gradient-to-br from-[var(--electric-blue)]/10 to-[var(--neighborhood-green)]/10 rounded-3xl p-6 border border-[var(--electric-blue)]/20"
        >
          <div className="flex items-start gap-3">
            <div className="p-2 rounded-xl bg-white">
              <Sparkles className="w-5 h-5 text-[var(--electric-blue)]" />
            </div>
            <div>
              <h3 className="font-semibold text-gray-900 mb-2">Your Activity Insights</h3>
              <div className="space-y-2 text-sm text-gray-700">
                <p>• Most active on weekends (7:00 PM - 10:00 PM)</p>
                <p>• Prefers events within 1 mile</p>
                <p>• High engagement with music & tech events</p>
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </div>
  );
}