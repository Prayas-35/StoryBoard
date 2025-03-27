"use client";

import { createConfig } from "@privy-io/wagmi";
import { lineaSepolia } from "viem/chains";
import { http, createStorage, cookieStorage } from "wagmi";

export const config = createConfig({
  chains: [lineaSepolia],
  storage: createStorage({
    storage: cookieStorage,
  }),
  transports: {
    [lineaSepolia.id]: http(),
  },
});
