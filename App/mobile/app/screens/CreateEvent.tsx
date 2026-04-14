import { useState } from 'react';
import { ArrowLeft, Upload, MapPin, Calendar, Clock, Users, Tag, DollarSign } from 'lucide-react';
import { useNavigate } from 'react-router';
import { motion } from 'motion/react';

export function CreateEvent() {
  const navigate = useNavigate();
  const [eventType, setEventType] = useState<string>('');
  const [formData, setFormData] = useState({
    title: '',
    category: '',
    date: '',
    time: '',
    location: '',
    description: '',
    maxAttendees: '',
    isFree: true
  });

  const eventTypes = [
    { id: 'tournament', label: 'Tournament', icon: '🏆', color: 'from-orange-400 to-red-500' },
    { id: 'charity', label: 'Charity', icon: '❤️', color: 'from-pink-400 to-rose-500' },
    { id: 'adoption', label: 'Pet Adoption', icon: '🐾', color: 'from-purple-400 to-indigo-500' },
    { id: 'community', label: 'Community', icon: '👥', color: 'from-green-400 to-emerald-500' },
    { id: 'workshop', label: 'Workshop', icon: '🎨', color: 'from-blue-400 to-cyan-500' },
    { id: 'other', label: 'Other', icon: '✨', color: 'from-yellow-400 to-amber-500' }
  ];

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    // Handle form submission
    console.log({ eventType, ...formData });
    navigate('/');
  };

  return (
    <div className="min-h-screen bg-gradient-to-b from-orange-50/40 to-amber-50/40 pb-24" style={{ backgroundColor: 'var(--bg-cream)' }}>
      {/* Header */}
      <div className="bg-white/70 backdrop-blur-xl border-b border-gray-200/50 sticky top-0 z-10">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center gap-3">
            <button
              onClick={() => navigate(-1)}
              className="p-2 rounded-xl hover:bg-gray-100 transition-all"
            >
              <ArrowLeft className="w-5 h-5 text-gray-900" />
            </button>
            <div>
              <h1 className="text-xl font-semibold text-gray-900">Create Event</h1>
              <p className="text-xs text-gray-600">Share with your neighborhood</p>
            </div>
          </div>
        </div>
      </div>

      <div className="max-w-md mx-auto px-4 py-6">
        {/* Event Type Selection */}
        {!eventType && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
          >
            <h2 className="font-semibold text-gray-900 mb-4">What type of event?</h2>
            <div className="grid grid-cols-2 gap-3">
              {eventTypes.map((type) => (
                <motion.button
                  key={type.id}
                  whileHover={{ scale: 1.05 }}
                  whileTap={{ scale: 0.95 }}
                  onClick={() => setEventType(type.id)}
                  className={`p-6 rounded-3xl bg-gradient-to-br ${type.color} text-white shadow-lg hover:shadow-xl transition-all`}
                >
                  <div className="text-4xl mb-2">{type.icon}</div>
                  <h3 className="font-semibold">{type.label}</h3>
                </motion.button>
              ))}
            </div>
          </motion.div>
        )}

        {/* Event Form */}
        {eventType && (
          <motion.form
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            onSubmit={handleSubmit}
            className="space-y-4"
          >
            {/* Selected Type Badge */}
            <div className="flex items-center justify-between bg-white/80 backdrop-blur-sm rounded-2xl p-4 border border-gray-200/50">
              <div className="flex items-center gap-3">
                <span className="text-2xl">
                  {eventTypes.find(t => t.id === eventType)?.icon}
                </span>
                <div>
                  <p className="text-xs text-gray-600">Event Type</p>
                  <p className="font-semibold text-gray-900">
                    {eventTypes.find(t => t.id === eventType)?.label}
                  </p>
                </div>
              </div>
              <button
                type="button"
                onClick={() => setEventType('')}
                className="text-sm text-[var(--electric-blue)] font-medium"
              >
                Change
              </button>
            </div>

            {/* Upload Image */}
            <div className="bg-white/80 backdrop-blur-sm rounded-3xl p-6 border border-gray-200/50">
              <label className="block mb-2 font-semibold text-gray-900">Event Photo</label>
              <div className="border-2 border-dashed border-gray-300 rounded-2xl p-8 text-center hover:border-[var(--electric-blue)] transition-all cursor-pointer">
                <Upload className="w-8 h-8 text-gray-400 mx-auto mb-2" />
                <p className="text-sm text-gray-600">Click to upload image</p>
                <p className="text-xs text-gray-500 mt-1">PNG, JPG up to 10MB</p>
              </div>
            </div>

            {/* Event Details */}
            <div className="bg-white/80 backdrop-blur-sm rounded-3xl p-6 border border-gray-200/50 space-y-4">
              <div>
                <label className="block mb-2 font-semibold text-gray-900">Event Title*</label>
                <input
                  type="text"
                  required
                  value={formData.title}
                  onChange={(e) => setFormData({ ...formData, title: e.target.value })}
                  placeholder="e.g., Neighborhood Basketball Tournament"
                  className="w-full px-4 py-3 rounded-xl bg-gray-50 border border-gray-200 focus:outline-none focus:ring-2 focus:ring-[var(--electric-blue)]/30"
                />
              </div>

              <div>
                <label className="block mb-2 font-semibold text-gray-900">Category*</label>
                <div className="relative">
                  <Tag className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                  <select
                    required
                    value={formData.category}
                    onChange={(e) => setFormData({ ...formData, category: e.target.value })}
                    className="w-full pl-11 pr-4 py-3 rounded-xl bg-gray-50 border border-gray-200 focus:outline-none focus:ring-2 focus:ring-[var(--electric-blue)]/30 appearance-none"
                  >
                    <option value="">Select category</option>
                    <option value="sports">Sports</option>
                    <option value="charity">Charity</option>
                    <option value="community">Community</option>
                    <option value="workshop">Workshop</option>
                    <option value="music">Music</option>
                    <option value="other">Other</option>
                  </select>
                </div>
              </div>

              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block mb-2 font-semibold text-gray-900">Date*</label>
                  <div className="relative">
                    <Calendar className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <input
                      type="date"
                      required
                      value={formData.date}
                      onChange={(e) => setFormData({ ...formData, date: e.target.value })}
                      className="w-full pl-11 pr-4 py-3 rounded-xl bg-gray-50 border border-gray-200 focus:outline-none focus:ring-2 focus:ring-[var(--electric-blue)]/30"
                    />
                  </div>
                </div>
                <div>
                  <label className="block mb-2 font-semibold text-gray-900">Time*</label>
                  <div className="relative">
                    <Clock className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                    <input
                      type="time"
                      required
                      value={formData.time}
                      onChange={(e) => setFormData({ ...formData, time: e.target.value })}
                      className="w-full pl-11 pr-4 py-3 rounded-xl bg-gray-50 border border-gray-200 focus:outline-none focus:ring-2 focus:ring-[var(--electric-blue)]/30"
                    />
                  </div>
                </div>
              </div>

              <div>
                <label className="block mb-2 font-semibold text-gray-900">Location*</label>
                <div className="relative">
                  <MapPin className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                  <input
                    type="text"
                    required
                    value={formData.location}
                    onChange={(e) => setFormData({ ...formData, location: e.target.value })}
                    placeholder="Enter address or place name"
                    className="w-full pl-11 pr-4 py-3 rounded-xl bg-gray-50 border border-gray-200 focus:outline-none focus:ring-2 focus:ring-[var(--electric-blue)]/30"
                  />
                </div>
              </div>

              <div>
                <label className="block mb-2 font-semibold text-gray-900">Description*</label>
                <textarea
                  required
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  placeholder="Describe your event..."
                  rows={4}
                  className="w-full px-4 py-3 rounded-xl bg-gray-50 border border-gray-200 focus:outline-none focus:ring-2 focus:ring-[var(--electric-blue)]/30 resize-none"
                />
              </div>

              <div>
                <label className="block mb-2 font-semibold text-gray-900">Max Attendees</label>
                <div className="relative">
                  <Users className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
                  <input
                    type="number"
                    value={formData.maxAttendees}
                    onChange={(e) => setFormData({ ...formData, maxAttendees: e.target.value })}
                    placeholder="Leave empty for unlimited"
                    className="w-full pl-11 pr-4 py-3 rounded-xl bg-gray-50 border border-gray-200 focus:outline-none focus:ring-2 focus:ring-[var(--electric-blue)]/30"
                  />
                </div>
              </div>

              <div className="flex items-center justify-between">
                <div>
                  <p className="font-semibold text-gray-900">Free Event</p>
                  <p className="text-xs text-gray-600">Is this event free to attend?</p>
                </div>
                <button
                  type="button"
                  onClick={() => setFormData({ ...formData, isFree: !formData.isFree })}
                  className={`relative w-14 h-8 rounded-full transition-all ${
                    formData.isFree ? 'bg-[var(--neighborhood-green)]' : 'bg-gray-300'
                  }`}
                >
                  <div className={`absolute top-1 w-6 h-6 bg-white rounded-full transition-all ${
                    formData.isFree ? 'left-7' : 'left-1'
                  }`}></div>
                </button>
              </div>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              className="w-full py-4 rounded-2xl bg-gradient-to-r from-[var(--neighborhood-green)] to-[var(--electric-blue)] text-white font-semibold shadow-lg hover:shadow-xl transition-all"
            >
              Publish Event
            </button>
          </motion.form>
        )}
      </div>
    </div>
  );
}