import { useState } from 'react';
import { Music, Briefcase, Users, Dumbbell, Cpu, Palette, Navigation, Search } from 'lucide-react';
import { Link } from 'react-router';
import { mockEvents } from '../data/mockData';
import { motion } from 'motion/react';

const categoryIcons = {
  music: Music,
  technology: Cpu,
  community: Users,
  sports: Dumbbell,
  workshop: Palette,
  concert: Music
};

const categoryColors = {
  music: '#8B5CF6',
  technology: '#3b82f6',
  community: '#22c55e',
  sports: '#f59e0b',
  workshop: '#ec4899',
  concert: '#8B5CF6'
};

export function MapView() {
  const [selectedCategory, setSelectedCategory] = useState<string | null>(null);

  const filteredEvents = selectedCategory
    ? mockEvents.filter(e => e.category === selectedCategory)
    : mockEvents;

  return (
    <div className="min-h-screen bg-gray-50 pb-24" style={{ backgroundColor: 'var(--bg-cream)' }}>
      {/* Header */}
      <div className="bg-white/70 backdrop-blur-xl border-b border-gray-200/50 sticky top-0 z-20">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-xl font-semibold">Nearby Events</h2>
            <button className="p-2 rounded-xl bg-[var(--electric-blue)] text-white">
              <Navigation className="w-5 h-5" />
            </button>
          </div>
          
          {/* Search */}
          <div className="relative mb-3">
            <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-4 h-4 text-gray-400" />
            <input
              type="text"
              placeholder="Search location..."
              className="w-full pl-10 pr-4 py-2.5 rounded-2xl bg-gray-100/80 border border-gray-200/50 focus:outline-none focus:ring-2 focus:ring-[var(--electric-blue)]/30"
            />
          </div>

          {/* Category Filters */}
          <div className="flex gap-2 overflow-x-auto pb-2 scrollbar-hide">
            <button
              onClick={() => setSelectedCategory(null)}
              className={`px-4 py-2 rounded-full text-sm whitespace-nowrap transition-all ${
                !selectedCategory
                  ? 'bg-gradient-to-r from-[var(--neighborhood-green)] to-[var(--electric-blue)] text-white'
                  : 'bg-gray-100 text-gray-700'
              }`}
            >
              All
            </button>
            {Array.from(new Set(mockEvents.map(e => e.category))).map(category => (
              <button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`px-4 py-2 rounded-full text-sm capitalize whitespace-nowrap transition-all ${
                  selectedCategory === category
                    ? 'bg-gradient-to-r from-[var(--neighborhood-green)] to-[var(--electric-blue)] text-white'
                    : 'bg-gray-100 text-gray-700'
                }`}
              >
                {category}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Mock Map Area */}
      <div className="max-w-md mx-auto">
        <div className="relative h-[400px] bg-gradient-to-br from-blue-100 to-green-100 overflow-hidden">
          {/* Grid overlay for map effect */}
          <div className="absolute inset-0 opacity-20">
            <div className="grid grid-cols-8 grid-rows-8 h-full w-full">
              {Array.from({ length: 64 }).map((_, i) => (
                <div key={i} className="border border-gray-400"></div>
              ))}
            </div>
          </div>

          {/* Map Markers */}
          {filteredEvents.map((event, index) => {
            const Icon = categoryIcons[event.category as keyof typeof categoryIcons] || Users;
            const color = categoryColors[event.category as keyof typeof categoryColors];
            
            // Generate pseudo-random positions for markers
            const positions = [
              { top: '20%', left: '30%' },
              { top: '40%', left: '60%' },
              { top: '60%', left: '25%' },
              { top: '30%', left: '70%' },
              { top: '70%', left: '50%' },
              { top: '50%', left: '40%' }
            ];
            
            const position = positions[index % positions.length];

            return (
              <motion.div
                key={event.id}
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ delay: index * 0.1 }}
                className="absolute"
                style={position}
              >
                <Link to={`/event/${event.id}`}>
                  <div className="relative group cursor-pointer">
                    {/* Marker Pin */}
                    <div 
                      className="w-12 h-12 rounded-full shadow-lg flex items-center justify-center transform transition-all group-hover:scale-110"
                      style={{ backgroundColor: color }}
                    >
                      <Icon className="w-6 h-6 text-white" />
                    </div>
                    {/* Marker Shadow */}
                    <div 
                      className="absolute -bottom-1 left-1/2 -translate-x-1/2 w-3 h-3 rounded-full opacity-30 blur-sm"
                      style={{ backgroundColor: color }}
                    ></div>
                    
                    {/* Hover Card */}
                    <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-2 opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none">
                      <div className="bg-white rounded-2xl shadow-xl p-3 w-48 border border-gray-200">
                        <h4 className="font-semibold text-sm mb-1 line-clamp-1">{event.title}</h4>
                        <p className="text-xs text-gray-600">{event.location}</p>
                        <p className="text-xs text-gray-500 mt-1">{event.distance}</p>
                      </div>
                    </div>
                  </div>
                </Link>
              </motion.div>
            );
          })}

          {/* User Location Indicator */}
          <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
            <div className="relative">
              <div className="w-4 h-4 rounded-full bg-[var(--electric-blue)] border-2 border-white shadow-lg"></div>
              <div className="absolute inset-0 rounded-full bg-[var(--electric-blue)] opacity-30 animate-ping"></div>
            </div>
          </div>
        </div>

        {/* Event List Below Map */}
        <div className="px-4 py-4 space-y-3">
          <h3 className="font-semibold text-gray-900">Events on Map ({filteredEvents.length})</h3>
          {filteredEvents.map((event) => (
            <Link key={event.id} to={`/event/${event.id}`}>
              <div className="bg-white rounded-2xl p-4 border border-gray-200/50 hover:shadow-md transition-all">
                <div className="flex gap-3">
                  <div 
                    className="w-12 h-12 rounded-xl flex items-center justify-center flex-shrink-0"
                    style={{ backgroundColor: `${categoryColors[event.category as keyof typeof categoryColors]}20` }}
                  >
                    {(() => {
                      const Icon = categoryIcons[event.category as keyof typeof categoryIcons] || Users;
                      return <Icon className="w-6 h-6" style={{ color: categoryColors[event.category as keyof typeof categoryColors] }} />;
                    })()}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="font-semibold text-sm mb-1 line-clamp-1">{event.title}</h4>
                    <p className="text-xs text-gray-600 line-clamp-1">{event.location}</p>
                    <div className="flex items-center gap-3 mt-1">
                      <span className="text-xs text-[var(--neighborhood-green)] font-medium">{event.distance}</span>
                      <span className="text-xs text-gray-500">{event.time}</span>
                    </div>
                  </div>
                </div>
              </div>
            </Link>
          ))}
        </div>
      </div>
    </div>
  );
}