import React from 'react';

export const LocationContext = React.createContext<{
  latitude: number;
  longitude: number;
} | null>(null);

