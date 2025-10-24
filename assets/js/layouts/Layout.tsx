import { Head } from "@inertiajs/react";
import React, { ReactNode, useEffect } from "react";

type LayoutProps = {
    title?: string;
    description?: string;
    children: ReactNode;
};

const Layout: React.FC<LayoutProps> = ({ title, description, children }) => {
    useEffect(() => {
        const prefersDark = window.matchMedia(
            "(prefers-color-scheme: dark)",
        ).matches;
        const theme = prefersDark ? "dark" : "light";

        document.documentElement.setAttribute("data-theme", theme);
    }, []);

    return (
        <>
            <Head>
                {title && <title>{title}</title>}
                {description && (
                    <meta name="description" content={description} />
                )}
            </Head>
            {children}
        </>
    );
};

export default Layout;
