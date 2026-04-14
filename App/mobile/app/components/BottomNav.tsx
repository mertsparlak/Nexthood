import { Home, Map, User, Sparkles, Plus } from 'lucide-react';
import { Link, useLocation } from 'react-router';

export function BottomNav() {
  const location = useLocation();
  
  const navItems = [
    { icon: Home, label: 'Discover', path: '/' },
    { icon: Map, label: 'Map', path: '/map' },
    { icon: Sparkles, label: 'AI Picks', path: '/ai-picks' },
    { icon: User, label: 'Profile', path: '/profile' }
  ];
  
  return (
    <>
      {/* Bottom Navigation */}
      <nav className="fixed bottom-0 left-0 right-0 bg-white/70 backdrop-blur-xl border-t border-gray-200/50 z-50">
        <div className="max-w-md mx-auto px-4 py-3">
          <div className="flex justify-around items-center">
            {navItems.map((item) => {
              const Icon = item.icon;
              const isActive = location.pathname === item.path;
              
              return (
                <Link
                  key={item.path}
                  to={item.path}
                  className="flex flex-col items-center gap-1 transition-all"
                >
                  <div className={`p-2 rounded-2xl transition-all ${
                    isActive 
                      ? 'bg-gradient-to-br from-[var(--neighborhood-green)] to-[var(--electric-blue)] text-white scale-110' 
                      : 'text-gray-500'
                  }`}>
                    <Icon className="w-5 h-5" />
                  </div>
                  <span className={`text-xs transition-all ${
                    isActive ? 'text-gray-900 font-medium' : 'text-gray-500'
                  }`}>
                    {item.label}
                  </span>
                </Link>
              );
            })}
          </div>
        </div>
      </nav>
    </>
  );
}