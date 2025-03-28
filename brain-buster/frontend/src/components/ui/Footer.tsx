const Footer = () => {
    const currentYear = new Date().getFullYear()

    return (
        <footer className="bg-violet-950 text-white/80 py-4 text-center text-sm">
            <div className="container mx-auto px-4">
                <p>
                    &copy; {currentYear} BrainBuster Quiz App | Teste dein Wissen im Solo- oder
                    Multiplayer-Modus
                </p>
            </div>
        </footer>
    )
}

export default Footer