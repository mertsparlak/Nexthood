import { Outlet, useLocation } from 'react-router';
import { BottomNav } from './BottomNav';

export function Layout() {
  const location = useLocation();
  
  // Hide bottom nav on event detail and create event pages
  const hideBottomNav = location.pathname.startsWith('/event/') || location.pathname === '/create-event';

  return (
    <div className="min-h-screen bg-gray-50" style={{ backgroundColor: 'var(--bg-cream)' }}>
      <Outlet />
      {!hideBottomNav && <BottomNav />}
    </div>
  );
}