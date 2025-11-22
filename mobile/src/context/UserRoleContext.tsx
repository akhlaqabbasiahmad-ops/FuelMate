import React from 'react';

export const UserRoleContext = React.createContext<{
  userRole: 'needy' | 'provider' | null;
  setUserRole: (role: 'needy' | 'provider') => void;
}>({
  userRole: null,
  setUserRole: () => {},
});

