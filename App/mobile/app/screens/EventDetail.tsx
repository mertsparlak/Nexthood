import { ArrowLeft, MapPin, Calendar, Clock, Users, Share2, Bookmark, Sparkles, Navigation } from 'lucide-react';
import { useParams, useNavigate } from 'react-router';
import { mockEvents } from '../data/mockData';
import { motion } from 'motion/react';

export function EventDetail() {
  const { id } = useParams();
  const navigate = useNavigate();
  const event = mockEvents.find(e => e.id === id);

  if (!event) {
    return (
      <div className="min-h-screen flex items-center justify-center">
        <p>Event not found</p>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-gray-50 pb-24" style={{ backgroundColor: 'var(--bg-cream)' }}>
      {/* Header Image */}
      <div className="relative h-80 overflow-hidden">
        <img
          src={event.imageUrl}
          alt={event.title}
          className="w-full h-full object-cover"
        />
        <div className="absolute inset-0 bg-gradient-to-b from-transparent to-black/50"></div>
        
        {/* Back Button */}
        <button
          onClick={() => navigate(-1)}
          className="absolute top-4 left-4 p-2 rounded-full bg-white/90 backdrop-blur-sm"
        >
          <ArrowLeft className="w-5 h-5 text-gray-900" />
        </button>

        {/* Action Buttons */}
        <div className="absolute top-4 right-4 flex gap-2">
          <button className="p-2 rounded-full bg-white/90 backdrop-blur-sm">
            <Share2 className="w-5 h-5 text-gray-900" />
          </button>
          <button className="p-2 rounded-full bg-white/90 backdrop-blur-sm">
            <Bookmark className="w-5 h-5 text-gray-900" />
          </button>
        </div>

        {/* AI Badge */}
        <div className="absolute bottom-4 right-4 px-3 py-1.5 rounded-full bg-white/90 backdrop-blur-sm flex items-center gap-2">
          <Sparkles className="w-4 h-4 text-[var(--electric-blue)]" />
          <span className="text-sm font-semibold">{event.aiScore}% Match</span>
        </div>
      </div>

      <div className="max-w-md mx-auto px-4">
        {/* Event Header */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="-mt-8 relative"
        >
          <div className="bg-white rounded-3xl p-6 shadow-lg border border-gray-200/50">
            <div className="flex items-start gap-3 mb-4">
              <div className="px-3 py-1.5 rounded-full bg-[var(--neighborhood-green)] text-white text-sm font-semibold capitalize">
                {event.category}
              </div>
              <div className="px-3 py-1.5 rounded-full bg-gray-100 text-gray-700 text-sm">
                {event.distance}
              </div>
            </div>

            <h1 className="text-2xl font-semibold text-gray-900 mb-4">
              {event.title}
            </h1>

            {/* Event Info Grid */}
            <div className="space-y-3">
              <div className="flex items-start gap-3">
                <div className="p-2 rounded-xl bg-[var(--electric-blue)]/10">
                  <Calendar className="w-5 h-5 text-[var(--electric-blue)]" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-900">Date & Time</p>
                  <p className="text-sm text-gray-600">{event.date}</p>
                  <p className="text-sm text-gray-600">{event.time}</p>
                </div>
              </div>

              <div className="flex items-start gap-3">
                <div className="p-2 rounded-xl bg-[var(--neighborhood-green)]/10">
                  <MapPin className="w-5 h-5 text-[var(--neighborhood-green)]" />
                </div>
                <div className="flex-1">
                  <p className="text-sm font-medium text-gray-900">Location</p>
                  <p className="text-sm text-gray-600">{event.location}</p>
                  <p className="text-sm text-gray-500">{event.address}</p>
                </div>
                <button className="p-2 rounded-xl bg-[var(--neighborhood-green)] text-white">
                  <Navigation className="w-4 h-4" />
                </button>
              </div>

              <div className="flex items-start gap-3">
                <div className="p-2 rounded-xl bg-purple-100">
                  <Users className="w-5 h-5 text-purple-600" />
                </div>
                <div>
                  <p className="text-sm font-medium text-gray-900">Attendees</p>
                  <p className="text-sm text-gray-600">{event.attendees} people attending</p>
                </div>
              </div>
            </div>
          </div>
        </motion.div>

        {/* AI Summary */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="mt-4"
        >
          <div className="bg-gradient-to-br from-[var(--electric-blue)]/10 to-[var(--neighborhood-green)]/10 rounded-3xl p-5 border border-[var(--electric-blue)]/20">
            <div className="flex items-start gap-3 mb-3">
              <div className="p-2 rounded-xl bg-white">
                <Sparkles className="w-5 h-5 text-[var(--electric-blue)]" />
              </div>
              <div>
                <h3 className="font-semibold text-gray-900">AI Insights</h3>
                <p className="text-xs text-gray-600 mt-1">Why we think you'll love this</p>
              </div>
            </div>
            <p className="text-sm text-gray-700 italic leading-relaxed">
              {event.aiSummary}
            </p>
          </div>
        </motion.div>

        {/* Description */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="mt-4"
        >
          <div className="bg-white rounded-3xl p-6 border border-gray-200/50">
            <h3 className="font-semibold text-gray-900 mb-3">About This Event</h3>
            <p className="text-sm text-gray-700 leading-relaxed">
              {event.description}
            </p>
          </div>
        </motion.div>

        {/* Action Buttons */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.3 }}
          className="mt-6 space-y-3"
        >
          <button className="w-full py-4 rounded-2xl bg-gradient-to-r from-[var(--neighborhood-green)] to-[var(--electric-blue)] text-white font-semibold shadow-lg hover:shadow-xl transition-all">
            Register for Event
          </button>
          <button className="w-full py-4 rounded-2xl bg-white border-2 border-gray-200 text-gray-900 font-semibold hover:bg-gray-50 transition-all">
            Add to Calendar
          </button>
        </motion.div>
      </div>
    </div>
  );
}