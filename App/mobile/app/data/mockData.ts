export interface Event {
  id: string;
  title: string;
  category: 'concert' | 'workshop' | 'community' | 'sports' | 'technology' | 'music';
  date: string;
  time: string;
  location: string;
  address: string;
  description: string;
  aiSummary: string;
  attendees: number;
  imageUrl: string;
  coordinates: {
    lat: number;
    lng: number;
  };
  aiScore: number; // AI recommendation score
  distance: string;
}

export interface Interest {
  id: string;
  name: string;
  icon: string;
  selected: boolean;
}

export const mockEvents: Event[] = [
  {
    id: '1',
    title: 'Jazz Night at Downtown Café',
    category: 'music',
    date: '2026-03-15',
    time: '7:00 PM',
    location: 'The Blue Note Café',
    address: '123 Main St, Downtown',
    description: 'Join us for an intimate jazz performance featuring local artists. Experience the vibrant sounds of live jazz in a cozy atmosphere. The evening will feature both classic jazz standards and original compositions.',
    aiSummary: 'AI detected: Live music, intimate venue, local artists. Matches your love for jazz and downtown events.',
    attendees: 48,
    imageUrl: 'https://images.unsplash.com/photo-1708743535943-fac86cd97e41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxqYXp6JTIwY29uY2VydCUyMGxpdmUlMjBtdXNpY3xlbnwxfHx8fDE3NzMxNDQ1OTh8MA&ixlib=rb-4.1.0&q=80&w=1080',
    coordinates: { lat: 40.7589, lng: -73.9851 },
    aiScore: 95,
    distance: '0.3 mi'
  },
  {
    id: '2',
    title: 'Community Garden Workshop',
    category: 'community',
    date: '2026-03-13',
    time: '10:00 AM',
    location: 'Greenfield Community Garden',
    address: '456 Park Ave, Northside',
    description: 'Learn sustainable gardening techniques and connect with your neighbors. This hands-on workshop covers composting, organic pest control, and seasonal planting strategies for urban gardens.',
    aiSummary: 'AI detected: Outdoor activity, sustainability focus, community building. Perfect for your eco-conscious interests.',
    attendees: 32,
    imageUrl: 'https://images.unsplash.com/photo-1763633923615-a2cdebba3bfd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxjb21tdW5pdHklMjBnYXJkZW4lMjB1cmJhbiUyMGZhcm1pbmd8ZW58MXx8fHwxNzczMTQ2MDUwfDA&ixlib=rb-4.1.0&q=80&w=1080',
    coordinates: { lat: 40.7614, lng: -73.9776 },
    aiScore: 88,
    distance: '0.8 mi'
  },
  {
    id: '3',
    title: 'Tech Meetup: AI & Local Communities',
    category: 'technology',
    date: '2026-03-16',
    time: '6:30 PM',
    location: 'Innovation Hub',
    address: '789 Tech Blvd, Tech District',
    description: 'Explore how AI is transforming neighborhood connections and local event discovery. Network with developers, designers, and community organizers working on hyperlocal solutions.',
    aiSummary: 'AI detected: Technology-focused, networking opportunity, AI/ML topics. Aligns with your tech interests and professional growth.',
    attendees: 67,
    imageUrl: 'https://images.unsplash.com/photo-1560439514-0fc9d2cd5e1b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHx0ZWNoJTIwbWVldHVwJTIwY29uZmVyZW5jZXxlbnwxfHx8fDE3NzMyMTk0Mzh8MA&ixlib=rb-4.1.0&q=80&w=1080',
    coordinates: { lat: 40.7549, lng: -73.9840 },
    aiScore: 92,
    distance: '1.2 mi'
  },
  {
    id: '4',
    title: 'Neighborhood Basketball Tournament',
    category: 'sports',
    date: '2026-03-14',
    time: '2:00 PM',
    location: 'Riverside Park Courts',
    address: '321 River Rd, Riverside',
    description: 'Annual 3v3 basketball tournament open to all skill levels. Teams will compete in a friendly competition with prizes for winners. Great opportunity to meet active neighbors.',
    aiSummary: 'AI detected: Team sports, outdoor activity, community competition. Matches your interest in staying active locally.',
    attendees: 124,
    imageUrl: 'https://images.unsplash.com/photo-1763893301002-47a8396f0643?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxiYXNrZXRiYWxsJTIwdG91cm5hbWVudCUyMG91dGRvb3J8ZW58MXx8fHwxNzczMjE5NDM5fDA&ixlib=rb-4.1.0&q=80&w=1080',
    coordinates: { lat: 40.7580, lng: -73.9855 },
    aiScore: 78,
    distance: '0.5 mi'
  },
  {
    id: '5',
    title: 'Pottery & Ceramics Workshop',
    category: 'workshop',
    date: '2026-03-17',
    time: '11:00 AM',
    location: 'Artisan Studio',
    address: '555 Craft Lane, Arts Quarter',
    description: 'Beginner-friendly pottery class where you\'ll learn hand-building techniques and create your own ceramic piece. All materials provided, and you can pick up your fired creation the following week.',
    aiSummary: 'AI detected: Creative workshop, hands-on learning, beginner-friendly. Great for exploring new hobbies in your area.',
    attendees: 18,
    imageUrl: 'https://images.unsplash.com/photo-1676125105332-608345abe20e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxwb3R0ZXJ5JTIwd29ya3Nob3AlMjBjZXJhbWljc3xlbnwxfHx8fDE3NzMyMTk0Mzl8MA&ixlib=rb-4.1.0&q=80&w=1080',
    coordinates: { lat: 40.7601, lng: -73.9808 },
    aiScore: 85,
    distance: '0.9 mi'
  },
  {
    id: '6',
    title: 'Sunday Farmers Market',
    category: 'community',
    date: '2026-03-16',
    time: '8:00 AM',
    location: 'City Square',
    address: '100 Central Plaza, Downtown',
    description: 'Weekly farmers market featuring local produce, artisanal goods, and live music. Support local farmers and makers while enjoying the community atmosphere.',
    aiSummary: 'AI detected: Local food, community gathering, weekly event. Matches your preference for supporting local businesses.',
    attendees: 203,
    imageUrl: 'https://images.unsplash.com/photo-1747503331142-27f458a1498c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxmYXJtZXJzJTIwbWFya2V0JTIwZnJlc2glMjBwcm9kdWNlfGVufDF8fHx8MTc3MzE0MTE0Nnww&ixlib=rb-4.1.0&q=80&w=1080',
    coordinates: { lat: 40.7595, lng: -73.9845 },
    aiScore: 81,
    distance: '0.4 mi'
  }
];

export const mockInterests: Interest[] = [
  { id: '1', name: 'Technology', icon: 'Cpu', selected: true },
  { id: '2', name: 'Music', icon: 'Music', selected: true },
  { id: '3', name: 'Sports', icon: 'Dumbbell', selected: false },
  { id: '4', name: 'Arts & Crafts', icon: 'Palette', selected: true },
  { id: '5', name: 'Food & Drink', icon: 'Coffee', selected: false },
  { id: '6', name: 'Community', icon: 'Users', selected: true },
  { id: '7', name: 'Nature', icon: 'Leaf', selected: false },
  { id: '8', name: 'Education', icon: 'GraduationCap', selected: false },
  { id: '9', name: 'Wellness', icon: 'Heart', selected: false },
  { id: '10', name: 'Business', icon: 'Briefcase', selected: false },
  { id: '11', name: 'Gaming', icon: 'Gamepad', selected: false },
  { id: '12', name: 'Photography', icon: 'Camera', selected: false }
];