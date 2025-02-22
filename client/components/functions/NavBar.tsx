"use client";
import type React from "react";
import { NotebookPen } from "lucide-react";
import Link from "next/link";
import LoginButton from "@/components/functions/ConnectButton";
import { ModeToggle } from "@/components/theme/themeSwitcher";
import { useRole } from "@/app/_contexts/roleContext";
import { useState, useEffect } from "react";
import { usePrivy } from "@privy-io/react-auth";
import { UserInterface } from "@/types";
import { useAccount } from "wagmi";

export default function NavBar() {
    const [role, setRole] = useState<string | null>(null);
    const { user } = usePrivy();
    const [userAddress, setUserAddress] = useState<string | null>(null);
    const [userData, setUserData] = useState<UserInterface | null>(null);
    const { address } = useAccount();

    useEffect(() => {
        if (address) {
            setUserAddress(address || user?.wallet?.address);
            // router.push("/");
        }
    }, [address]);

    const walletAddress = address || user?.wallet?.address;

    useEffect(() => {
        if (walletAddress && walletAddress.startsWith("0x")) {
            getUser();
        }
    }, [walletAddress, user, address]);

    const getUser = async () => {
        const response = await fetch(`/api/getUser?address=${walletAddress}`);
        const data = await response.json();
        if (data.user) {
            setUserData(data.user);
            setRole(data.user.role);
            console.log(userData);
        }
    };

    return (
        <header className="sticky top-0 z-50 w-full border-b-8 dark:border-b-4 border-border dark:bg-bg bg-violet-200 h-20 flex items-center">
            <div className="container flex h-16 items-center justify-between">
                <Link href="/">
                    <div className="flex items-center gap-2">
                        <NotebookPen className="h-6 w-6 dark:text-purple-400 text-purple-600" />
                        <span className="text-2xl font-bold bg-gradient-to-r from-purple-600 dark:from-purple-400 to-black dark:to-white bg-clip-text text-transparent">StoryBoard</span>
                    </div>
                </Link>
                <nav className="hidden md:flex gap-6 items-center">
                    {role === "Creator" && (
                        <Link
                            href="/creator/dashboard"
                            className="text-lg font-bold hover:text-primary transition duration-300 ease-in-out transform hover:scale-110"
                        >
                            Creators
                        </Link>
                    )}
                    {role === "Reader" && (
                        <Link
                            href="/reader/dashboard"
                            className="text-lg font-bold hover:text-primary transition duration-300 ease-in-out transform hover:scale-110"
                        >
                            Readers
                        </Link>
                    )}
                    <Link
                        href="/reader/dashboard"
                        className="text-lg font-bold hover:text-primary transition duration-300 ease-in-out transform hover:scale-110"
                    >
                        $STORY Tokens
                    </Link>
                    <Link
                        href="/setup"
                        className="text-lg font-bold hover:text-primary transition duration-300 ease-in-out transform hover:scale-110"
                    >
                        Set Up
                    </Link>
                </nav>
                <div className="flex items-center gap-3">
                    <ModeToggle />
                    <LoginButton />
                </div>
            </div>
        </header>
    );
}
