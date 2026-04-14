import { Home } from 'lucide-react';
import { Link } from 'react-router';

export function NotFound() {
  return (
    <div className="min-h-screen bg-gradient-to-b from-orange-50/40 to-amber-50/40 flex items-center justify-center px-4" style={{ backgroundColor: 'var(--bg-cream)' }}>
      <div className="text-center">
        <div className="inline-flex items-center justify-center w-20 h-20 rounded-full bg-gradient-to-br from-[var(--neighborhood-green)] to-[var(--electric-blue)] mb-6">
          <span className="text-3xl font-bold text-white">404</span>
        </div>
        <h1 className="text-2xl font-semibold text-gray-900 mb-2">
          Page Not Found
        </h1>
        <p className="text-gray-600 mb-8">
          Looks like you've wandered outside your neighborhood
        </p>
        <Link to="/">
          <button className="px-6 py-3 rounded-2xl bg-gradient-to-r from-[var(--neighborhood-green)] to-[var(--electric-blue)] text-white font-semibold flex items-center gap-2 mx-auto">
            <Home className="w-5 h-5" />
            Back to Home
          </button>
        </Link>
      </div>
    </div>
  );
}