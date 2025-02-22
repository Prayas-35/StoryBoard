"use client"

import React, { createContext, useContext, useState, useEffect } from 'react';
import Cookies from 'js-cookie';

const RoleContext = createContext();

export const useRole = () => useContext(RoleContext);

export const RoleProvider = ({ children }) => {
  const [role, setRole] = useState(null);

  const login = (role) => {
    setRole(role);
    Cookies.set('role', role, { expires: 30 });
  };

  const logout = () => {
    setRole(null);
    Cookies.remove('role');
  };

  useEffect(() => {
    const roleFromCookie = Cookies.get('role');
    if (roleFromCookie) {
      setRole(roleFromCookie);
    }
  }, []);

  return (
    <RoleContext.Provider value={{ role, login, logout }}>
      {children}
    </RoleContext.Provider>
  );
};
