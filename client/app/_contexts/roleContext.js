"use client"

import React, { createContext, useContext, useState, useEffect } from 'react';
import Cookies from 'js-cookie';

const RoleContext = createContext();

export const useRole = () => useContext(RoleContext);

export const RoleProvider = ({ children }) => {
  const [role, setRole] = useState(null);
  const [address, setAddress] = useState(null);

  const login = (role, address) => {
    setRole(role);
    setAddress(address)
    Cookies.set('role', role, { expires: 30 });
    Cookies.set('address', address, { expires: 30 })
  };

  const roleLogout = () => {
    setRole(null);
    setAddress(null);
    console.log('Before logout:', Cookies.get('role'), Cookies.get('address'));
    Cookies.remove('role', { path: '/' });
    Cookies.remove('address', { path: '/' });
    console.log('After logout:', Cookies.get('role'), Cookies.get('address'));
  };

  useEffect(() => {
    const roleFromCookie = Cookies.get('role');
    const addressFromCookie = Cookies.get('address')
    if (roleFromCookie) {
      setRole(roleFromCookie);
    }
    if (addressFromCookie) {
      setAddress(addressFromCookie);
    }
  }, []);

  return (
    <RoleContext.Provider value={{ role, address, login, roleLogout }}>
      {children}
    </RoleContext.Provider>
  );
};
