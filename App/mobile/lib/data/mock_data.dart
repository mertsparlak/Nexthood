import 'models/event.dart';
import 'models/interest.dart';

const List<Event> mockEvents = [
  Event(
    id: '1',
    title: 'Jazz Night at Downtown Café',
    category: 'music',
    date: '2026-03-15',
    time: '7:00 PM',
    location: 'The Blue Note Café',
    address: '123 Main St, Downtown',
    description:
        'Join us for an intimate jazz performance featuring local artists. Experience the vibrant sounds of live jazz in a cozy atmosphere. The evening will feature both classic jazz standards and original compositions.',
    aiSummary:
        'AI detected: Live music, intimate venue, local artists. Matches your love for jazz and downtown events.',
    attendees: 48,
    imageUrl:
        'https://images.unsplash.com/photo-1708743535943-fac86cd97e41?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    lat: 40.7589,
    lng: -73.9851,
    aiScore: 95,
    distance: '0.3 mi',
  ),
  Event(
    id: '2',
    title: 'Community Garden Workshop',
    category: 'community',
    date: '2026-03-13',
    time: '10:00 AM',
    location: 'Greenfield Community Garden',
    address: '456 Park Ave, Northside',
    description:
        'Learn sustainable gardening techniques and connect with your neighbors. This hands-on workshop covers composting, organic pest control, and seasonal planting strategies for urban gardens.',
    aiSummary:
        'AI detected: Outdoor activity, sustainability focus, community building. Perfect for your eco-conscious interests.',
    attendees: 32,
    imageUrl:
        'https://images.unsplash.com/photo-1763633923615-a2cdebba3bfd?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    lat: 40.7614,
    lng: -73.9776,
    aiScore: 88,
    distance: '0.8 mi',
  ),
  Event(
    id: '3',
    title: 'Tech Meetup: AI & Local Communities',
    category: 'technology',
    date: '2026-03-16',
    time: '6:30 PM',
    location: 'Innovation Hub',
    address: '789 Tech Blvd, Tech District',
    description:
        'Explore how AI is transforming neighborhood connections and local event discovery. Network with developers, designers, and community organizers working on hyperlocal solutions.',
    aiSummary:
        'AI detected: Technology-focused, networking opportunity, AI/ML topics. Aligns with your tech interests and professional growth.',
    attendees: 67,
    imageUrl:
        'https://images.unsplash.com/photo-1560439514-0fc9d2cd5e1b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    lat: 40.7549,
    lng: -73.9840,
    aiScore: 92,
    distance: '1.2 mi',
  ),
  Event(
    id: '4',
    title: 'Neighborhood Basketball Tournament',
    category: 'sports',
    date: '2026-03-14',
    time: '2:00 PM',
    location: 'Riverside Park Courts',
    address: '321 River Rd, Riverside',
    description:
        'Annual 3v3 basketball tournament open to all skill levels. Teams will compete in a friendly competition with prizes for winners. Great opportunity to meet active neighbors.',
    aiSummary:
        'AI detected: Team sports, outdoor activity, community competition. Matches your interest in staying active locally.',
    attendees: 124,
    imageUrl:
        'https://images.unsplash.com/photo-1763893301002-47a8396f0643?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    lat: 40.7580,
    lng: -73.9855,
    aiScore: 78,
    distance: '0.5 mi',
  ),
  Event(
    id: '5',
    title: 'Pottery & Ceramics Workshop',
    category: 'workshop',
    date: '2026-03-17',
    time: '11:00 AM',
    location: 'Artisan Studio',
    address: '555 Craft Lane, Arts Quarter',
    description:
        "Beginner-friendly pottery class where you'll learn hand-building techniques and create your own ceramic piece. All materials provided, and you can pick up your fired creation the following week.",
    aiSummary:
        'AI detected: Creative workshop, hands-on learning, beginner-friendly. Great for exploring new hobbies in your area.',
    attendees: 18,
    imageUrl:
        'https://images.unsplash.com/photo-1676125105332-608345abe20e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    lat: 40.7601,
    lng: -73.9808,
    aiScore: 85,
    distance: '0.9 mi',
  ),
  Event(
    id: '6',
    title: 'Sunday Farmers Market',
    category: 'community',
    date: '2026-03-16',
    time: '8:00 AM',
    location: 'City Square',
    address: '100 Central Plaza, Downtown',
    description:
        'Weekly farmers market featuring local produce, artisanal goods, and live music. Support local farmers and makers while enjoying the community atmosphere.',
    aiSummary:
        'AI detected: Local food, community gathering, weekly event. Matches your preference for supporting local businesses.',
    attendees: 203,
    imageUrl:
        'https://images.unsplash.com/photo-1747503331142-27f458a1498c?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
    lat: 40.7595,
    lng: -73.9845,
    aiScore: 81,
    distance: '0.4 mi',
  ),
];

List<Interest> getMockInterests() => [
      Interest(id: '1', name: 'Technology', icon: 'Cpu', selected: true),
      Interest(id: '2', name: 'Music', icon: 'Music', selected: true),
      Interest(id: '3', name: 'Sports', icon: 'Dumbbell', selected: false),
      Interest(id: '4', name: 'Arts & Crafts', icon: 'Palette', selected: true),
      Interest(id: '5', name: 'Food & Drink', icon: 'Coffee', selected: false),
      Interest(id: '6', name: 'Community', icon: 'Users', selected: true),
      Interest(id: '7', name: 'Nature', icon: 'Leaf', selected: false),
      Interest(id: '8', name: 'Education', icon: 'GraduationCap', selected: false),
      Interest(id: '9', name: 'Wellness', icon: 'Heart', selected: false),
      Interest(id: '10', name: 'Business', icon: 'Briefcase', selected: false),
      Interest(id: '11', name: 'Gaming', icon: 'Gamepad', selected: false),
      Interest(id: '12', name: 'Photography', icon: 'Camera', selected: false),
    ];
