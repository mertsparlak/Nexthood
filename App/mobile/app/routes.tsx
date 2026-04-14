import { createBrowserRouter } from 'react-router';
import { Layout } from './components/Layout';
import { DiscoveryFeed } from './screens/DiscoveryFeed';
import { MapView } from './screens/MapView';
import { EventDetail } from './screens/EventDetail';
import { InterestProfile } from './screens/InterestProfile';
import { AIPicks } from './screens/AIPicks';
import { CreateEvent } from './screens/CreateEvent';
import { NotFound } from './screens/NotFound';

export const router = createBrowserRouter([
  {
    path: '/',
    Component: Layout,
    children: [
      { index: true, Component: DiscoveryFeed },
      { path: 'map', Component: MapView },
      { path: 'ai-picks', Component: AIPicks },
      { path: 'profile', Component: InterestProfile },
      { path: 'event/:id', Component: EventDetail },
      { path: 'create-event', Component: CreateEvent },
      { path: '*', Component: NotFound }
    ]
  }
]);