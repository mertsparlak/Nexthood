import { useState } from 'react';
import { Sparkles, Cpu, Music, Dumbbell, Palette, Coffee, Users, Leaf, GraduationCap, Heart, Briefcase, Gamepad, Camera, MapPin, Edit2, Settings } from 'lucide-react';
import { mockInterests } from '../data/mockData';
import { motion } from 'motion/react';

const iconMap: Record<string, any> = {
  Cpu, Music, Dumbbell, Palette, Coffee, Users, Leaf, GraduationCap, Heart, Briefcase, Gamepad, Camera
};

export function InterestProfile() {
  const [interests, setInterests] = useState(mockInterests);
  const [radiusMeters, setRadiusMeters] = useState(100);

  const toggleInterest = (id: string) => {
    setInterests(interests.map(interest =>
      interest.id === id ? { ...interest, selected: !interest.selected } : interest
    ));
  };

  const selectedCount = interests.filter(i => i.selected).length;

  return (
    <div className="min-h-screen bg-gradient-to-b from-orange-50/40 to-amber-50/40 pb-24" style={{ backgroundColor: 'var(--bg-cream)' }}>
      {/* Header */}
      <div className="bg-white/70 backdrop-blur-xl border-b border-gray-200/50">
        <div className="max-w-md mx-auto px-4 py-4">
          <div className="flex items-center justify-between">
            <h1 className="text-xl font-semibold text-gray-900">Profile</h1>
            <button className="p-2 rounded-xl hover:bg-gray-100 transition-all">
              <Settings className="w-5 h-5 text-gray-700" />
            </button>
          </div>
        </div>
      </div>

      <div className="max-w-md mx-auto px-4 py-6 space-y-4">
        {/* User Profile Card */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          className="bg-white/80 backdrop-blur-sm rounded-3xl p-6 border border-gray-200/50"
        >
          <div className="flex items-start gap-4 mb-4">
            <div className="relative">
              <div className="w-20 h-20 rounded-full bg-gradient-to-br from-[var(--neighborhood-green)] to-[var(--electric-blue)] flex items-center justify-center text-white text-2xl font-bold">
                JD
              </div>
              <button className="absolute bottom-0 right-0 p-1.5 rounded-full bg-white border-2 border-gray-200 hover:bg-gray-50 transition-all">
                <Edit2 className="w-3 h-3 text-gray-700" />
              </button>
            </div>
            <div className="flex-1">
              <h2 className="text-xl font-semibold text-gray-900">John Doe</h2>
              <p className="text-sm text-gray-600 mb-2">john.doe@email.com</p>
              <div className="flex items-center gap-1 text-sm text-gray-600">
                <MapPin className="w-4 h-4 text-[var(--neighborhood-green)]" />
                <span>Manhattan, New York</span>
              </div>
            </div>
          </div>

          <div className="flex gap-2">
            <button className="flex-1 py-2 px-4 rounded-xl bg-gradient-to-r from-[var(--neighborhood-green)] to-[var(--electric-blue)] text-white text-sm font-semibold">
              Edit Profile
            </button>
            <button className="flex-1 py-2 px-4 rounded-xl bg-gray-100 text-gray-700 text-sm font-semibold">
              Share Profile
            </button>
          </div>
        </motion.div>

        {/* Location Scope Map */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.1 }}
          className="bg-white/80 backdrop-blur-sm rounded-3xl p-6 border border-gray-200/50"
        >
          <div className="flex items-center justify-between mb-4">
            <div>
              <h3 className="font-semibold text-gray-900">Discovery Radius</h3>
              <p className="text-xs text-gray-600">Events within {radiusMeters}m from you</p>
            </div>
            <div className="px-3 py-1.5 rounded-full bg-gradient-to-r from-[var(--neighborhood-green)] to-[var(--electric-blue)] text-white text-sm font-semibold">
              {radiusMeters}m
            </div>
          </div>

          {/* Map Visualization */}
          <div className="relative w-full h-64 bg-gradient-to-br from-blue-100 to-green-100 rounded-2xl overflow-hidden mb-4">
            {/* Grid overlay */}
            <div className="absolute inset-0 opacity-10">
              <div className="grid grid-cols-6 grid-rows-6 h-full w-full">
                {Array.from({ length: 36 }).map((_, i) => (
                  <div key={i} className="border border-gray-400"></div>
                ))}
              </div>
            </div>

            {/* Radius Circle */}
            <div className="absolute inset-0 flex items-center justify-center">
              <motion.div
                initial={{ scale: 0 }}
                animate={{ scale: 1 }}
                transition={{ duration: 0.5 }}
                className="relative"
                style={{
                  width: `${Math.min(radiusMeters / 100 * 120, 220)}px`,
                  height: `${Math.min(radiusMeters / 100 * 120, 220)}px`
                }}
              >
                {/* Outer radius circle */}
                <div className="absolute inset-0 rounded-full border-4 border-[var(--electric-blue)]/30 bg-[var(--electric-blue)]/5"></div>
                
                {/* Middle ring */}
                <div className="absolute inset-[20%] rounded-full border-2 border-[var(--neighborhood-green)]/20"></div>
                
                {/* User position in center */}
                <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2">
                  <div className="relative">
                    <div className="w-12 h-12 rounded-full bg-gradient-to-br from-[var(--neighborhood-green)] to-[var(--electric-blue)] flex items-center justify-center text-white font-bold border-4 border-white shadow-lg">
                      JD
                    </div>
                    {/* Pulsing effect */}
                    <div className="absolute inset-0 rounded-full bg-[var(--electric-blue)] opacity-30 animate-ping"></div>
                  </div>
                </div>

                {/* Radius label */}
                <div className="absolute -bottom-8 left-1/2 -translate-x-1/2 px-2 py-1 rounded-lg bg-white/90 backdrop-blur-sm text-xs font-semibold text-gray-700 shadow-sm">
                  {radiusMeters}m radius
                </div>
              </motion.div>
            </div>
          </div>

          {/* Radius Slider */}
          <div className="space-y-2">
            <div className="flex justify-between text-xs text-gray-600">
              <span>50m</span>
              <span>500m</span>
            </div>
            <input
              type="range"
              min="50"
              max="500"
              step="50"
              value={radiusMeters}
              onChange={(e) => setRadiusMeters(Number(e.target.value))}
              className="w-full h-2 bg-gray-200 rounded-full appearance-none cursor-pointer [&::-webkit-slider-thumb]:appearance-none [&::-webkit-slider-thumb]:w-5 [&::-webkit-slider-thumb]:h-5 [&::-webkit-slider-thumb]:rounded-full [&::-webkit-slider-thumb]:bg-gradient-to-r [&::-webkit-slider-thumb]:from-[var(--neighborhood-green)] [&::-webkit-slider-thumb]:to-[var(--electric-blue)] [&::-webkit-slider-thumb]:cursor-pointer"
            />
          </div>
        </motion.div>

        {/* Interests Section - Compact */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ delay: 0.2 }}
          className="bg-white/80 backdrop-blur-sm rounded-3xl p-5 border border-gray-200/50"
        >
          <div className="flex items-center justify-between mb-3">
            <div>
              <h3 className="font-semibold text-gray-900">Your Interests</h3>
              <p className="text-xs text-gray-600">{selectedCount} selected</p>
            </div>
            <Sparkles className="w-5 h-5 text-[var(--electric-blue)]" />
          </div>

          {/* Compact Grid */}
          <div className="grid grid-cols-3 gap-2">
            {interests.map((interest) => {
              const Icon = iconMap[interest.icon];
              
              return (
                <button
                  key={interest.id}
                  onClick={() => toggleInterest(interest.id)}
                  className={`p-3 rounded-2xl border transition-all ${
                    interest.selected
                      ? 'bg-gradient-to-br from-[var(--neighborhood-green)] to-[var(--electric-blue)] border-transparent text-white scale-105'
                      : 'bg-white border-gray-200 text-gray-700 hover:border-[var(--electric-blue)]/30'
                  }`}
                >
                  <div className={`w-8 h-8 rounded-xl flex items-center justify-center mb-1.5 mx-auto ${
                    interest.selected ? 'bg-white/20' : 'bg-gray-100'
                  }`}>
                    <Icon className={`w-4 h-4 ${interest.selected ? 'text-white' : 'text-gray-700'}`} />
                  </div>
                  <p className="text-xs font-medium text-center line-clamp-1">
                    {interest.name}
                  </p>
                </button>
              );
            })}
          </div>

          <button className="w-full mt-4 py-2.5 rounded-xl bg-gray-100 text-gray-700 text-sm font-semibold hover:bg-gray-200 transition-all">
            Save Preferences
          </button>
        </motion.div>
      </div>
    </div>
  );
}