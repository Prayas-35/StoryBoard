"use client";

import { useState, useEffect } from "react";
import { usePrivy } from "@privy-io/react-auth";
import { useAccount, useDisconnect, useReadContract, useBalance } from "wagmi";
import { Button } from "@/components/ui/button";
import {
    DropdownMenu,
    DropdownMenuContent,
    DropdownMenuItem,
    DropdownMenuSeparator,
    DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { ChevronDown } from "lucide-react";
import { lineaSepolia } from "viem/chains";
import { formatEther } from "viem";
import { UserInterface } from "@/types";
import { abi, contractAddress } from "@/app/abi";
import { useRole } from "@/app/_contexts/roleContext";
import { useRouter } from "next/navigation";

export default function LoginButton() {
    const { ready, authenticated, login, logout, user } = usePrivy();
    const [userAddress, setUserAddress] = useState<string | null>(null);
    const [tokenBalance, setTokenBalance] = useState<string | null>(null);
    const [userData, setUserData] = useState<UserInterface | null>(null);
    const { address } = useAccount();
    const { disconnect } = useDisconnect();
    const { login: roleLogin, roleLogout, role } = useRole();
    const balance = useBalance({
        address: address,
        chainId: lineaSepolia.id,
    });
    const router = useRouter()

    const result = useReadContract({
        abi,
        address: contractAddress,
        functionName: 'balanceOf',
        args: [userAddress],
    })

    useEffect(() => {
        if (address) {
            setUserAddress(address || user?.wallet?.address);
            setTokenBalance(result.data ? result.data.toString() : '0');
            roleLogin(userData?.role, userAddress)
            // router.push("/");
        }
    }, [address, result]);

    const handleLogout = () => {
        roleLogout()
        logout();
        disconnect();
        setUserAddress(null);
        router.push("/");
    };

    const truncateAddress = (address: string) => {
        return `${address.slice(0, 6)}...${address.slice(-4)}`;
    };

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
            console.log(userData);
        }
    };

    const handleLogin = async () => {
        login();
        if (!role) {
            router.push("/setup");
        } else {
            router.push("/");
        }
    }

    if (!ready || !authenticated || !userAddress || !user?.wallet?.address || !walletAddress) {
        return <Button onClick={() => handleLogin()}>Connect Wallet</Button>;
    }

    return (
        <DropdownMenu>
            <DropdownMenuTrigger asChild>
                <Button variant="default" className="justify-between">
                    {truncateAddress(userAddress || user?.wallet?.address)}
                    <ChevronDown className="h-4 w-4 opacity-50" />
                </Button>
            </DropdownMenuTrigger>
            <DropdownMenuContent align="end">
                <DropdownMenuItem className="flex-col items-start">
                    <div className="font-medium">Username</div>
                    <div className="text-xs text-muted-foreground">
                        {userData ? userData.alias ?? "Error" : "No Alias Set"}
                    </div>
                </DropdownMenuItem>
                <DropdownMenuItem className="flex-col items-start">
                    <div className="font-medium">$STORY</div>
                    <div className="text-xs text-muted-foreground">
                        {tokenBalance ? Number(formatEther(BigInt(tokenBalance))).toFixed(3) : 0}
                    </div>
                </DropdownMenuItem>
                <DropdownMenuItem className="flex-col items-start">
                    <div className="font-medium">Role</div>
                    <div className="text-xs text-muted-foreground">
                        {userData ? userData.role ?? "Error" : "No Role Set"}
                    </div>
                </DropdownMenuItem>
                <DropdownMenuItem className="flex-col items-start">
                    <div className="font-medium">Balance</div>
                    <div className="text-xs text-muted-foreground">
                        {balance.data?.value
                            ? Number(formatEther(balance.data.value)).toFixed(3)
                            : 0}{" "}
                        {balance.data?.symbol}
                    </div>
                </DropdownMenuItem>
                <DropdownMenuSeparator />
                <DropdownMenuItem className="cursor-pointer" onClick={handleLogout}>
                    Disconnect
                </DropdownMenuItem>
            </DropdownMenuContent>
        </DropdownMenu>
    );
}
