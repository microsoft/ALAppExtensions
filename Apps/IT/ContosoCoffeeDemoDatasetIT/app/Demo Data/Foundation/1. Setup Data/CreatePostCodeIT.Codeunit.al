codeunit 12203 "Create Post Code IT"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    // TODO: MS
    // Discuss it
    // Maybe a service provide a better list of post codes?
    // This can be the same for now, then we convert to a list later.

    // Keep as it is for now
    // Wael

    trigger OnRun()
    var
        ContosoPostCodeIT: Codeunit "Contoso Post Code IT";
        CreateCountryRegion: Codeunit "Create Country/Region";
    begin
        ContosoPostCodeIT.InsertPostCode('00100', RomaLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('10100', TorinoLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('16011', ArenzanoLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('16100', GenovaLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('16143', GenovaLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('19100', LaSpeziaLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('20099', SestoSanGiovanniLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('20100', MilanoLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('20147', MilanoLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('21047', VareseLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('26100', CremonaLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('35100', PadovaLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('37100', VeronaLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('39100', BolzanoLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('42100', ReggioEmiliaLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('43100', ParmaLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('57100', LivornoLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('61100', SantaVenerandaLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('62100', MacerataLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('67067', PescinaLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('67100', LAquilaLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('80100', NapoliLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('90100', PalermoLbl, CreateCountryRegion.IT());
        ContosoPostCodeIT.InsertPostCode('GB-B27 4KT', BirminghamLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-B31 2AL', BirminghamLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-B32 4TF', SparkhillBirminghamLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-B68 5TT', BromsgroveLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-BA24 6KS', BathLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-BR1 2ES', BromleyLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-BS3 6KL', BristolLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-CB3 7GG', CambridgeLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-CF22 1XU', CardiffLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-CT6 21ND', HytheLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-CV6 1GY', CoventryLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-DA5 3EF', SidcupLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-DY5 4DJ', DudleyLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-E12 5TG', EdinburghLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-EH16 8JS', EdinburghLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-IB7 7VN', GainsboroughLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-L18 6SA', LiverpoolLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-LE16 7YH', LeicesterLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-LL6 5GB', RhylLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-LN23 6GS', LincolnLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-LU3 4FY', LutonLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-M61 2YG', ManchesterLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-ME5 6RL', MaidstoneLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-MK21 7GG', BletchleyLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-MK41 5AE', BedfordLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-MO2 4RT', ManchesterLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-N12 5XY', LondonLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-N16 34Z', LondonLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-NE21 3YG', NewcastleLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-NP5 6GH', NewportLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-OX16 0UA', CheddingtonLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-PE17 4RN', CambridgeLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-PE21 3TG', PeterboroughLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-PE23 5IK', KingsLynnLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-PL14 5GB', PlymouthLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-PO21 6HG', SouthseaPortsmouthLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-PO7 2HI', PortsmouthLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-SA1 2HS', SwanseaLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-SA3 7HI', StratfordLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-SK21 5DL', MacclesfieldLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-TA3 4FD', NewquayLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-TN27 6YD', AshfordLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-TQ17 8HB', BrixhamLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-W1 3AL', LondonLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-W2 8HG', LondonLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-WC1 2GS', WestEndLaneLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-WC1 3DG', LondonLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-WD1 6YG', WatfordLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-WD2 4RG', WatfordLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-WD6 8UY', BorehamwoodLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-WD6 9HY', BorehamwoodLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-GL1 9HM', GloucesterLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-GL78 5TT', CheltenhamLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-GU3 2SE', GuildfordLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-GU7 5GT', GuildfordLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-HG1 7YW', RiponLbl, CreateCountryRegion.GB());
        ContosoPostCodeIT.InsertPostCode('GB-HP43 2AY', TringLbl, CreateCountryRegion.GB());
    end;

    var
        TringLbl: Label 'Tring', MaxLength = 30;
        RiponLbl: Label 'Ripon', MaxLength = 30;
        GuildfordLbl: Label 'Guildford', MaxLength = 30;
        CheltenhamLbl: Label 'Cheltenham', MaxLength = 30;
        GloucesterLbl: Label 'Gloucester', MaxLength = 30;
        RomaLbl: Label 'Roma', MaxLength = 30;
        TorinoLbl: Label 'Torino', MaxLength = 30;
        ArenzanoLbl: Label 'Arenzano', MaxLength = 30;
        GenovaLbl: Label 'Genova', MaxLength = 30;
        LaSpeziaLbl: Label 'La Spezia', MaxLength = 30;
        SestoSanGiovanniLbl: Label 'Sesto San Giovanni', MaxLength = 30;
        MilanoLbl: Label 'Milano', MaxLength = 30;
        VareseLbl: Label 'Varese', MaxLength = 30;
        CremonaLbl: Label 'Cremona', MaxLength = 30;
        PadovaLbl: Label 'Padova', MaxLength = 30;
        VeronaLbl: Label 'Verona', MaxLength = 30;
        BolzanoLbl: Label 'Bolzano', MaxLength = 30;
        ReggioEmiliaLbl: Label 'Reggio Emilia', MaxLength = 30;
        ParmaLbl: Label 'Parma', MaxLength = 30;
        LivornoLbl: Label 'Livorno', MaxLength = 30;
        SantaVenerandaLbl: Label 'Santa Veneranda', MaxLength = 30;
        MacerataLbl: Label 'Macerata', MaxLength = 30;
        PescinaLbl: Label 'Pescina', MaxLength = 30;
        LAquilaLbl: Label 'L''Aquila', MaxLength = 30;
        NapoliLbl: Label 'Napoli', MaxLength = 30;
        PalermoLbl: Label 'Palermo', MaxLength = 30;
        BirminghamLbl: Label 'Birmingham', MaxLength = 30;
        SparkhillBirminghamLbl: Label 'Sparkhill, Birmingham', MaxLength = 30;
        BromsgroveLbl: Label 'Bromsgrove', MaxLength = 30;
        BathLbl: Label 'Bath', MaxLength = 30;
        BromleyLbl: Label 'Bromley', MaxLength = 30;
        BristolLbl: Label 'Bristol', MaxLength = 30;
        CambridgeLbl: Label 'Cambridge', MaxLength = 30;
        CardiffLbl: Label 'Cardiff', MaxLength = 30;
        HytheLbl: Label 'Hythe', MaxLength = 30;
        CoventryLbl: Label 'Coventry', MaxLength = 30;
        SidcupLbl: Label 'Sidcup', MaxLength = 30;
        DudleyLbl: Label 'Dudley', MaxLength = 30;
        EdinburghLbl: Label 'Edinburgh', MaxLength = 30;
        GainsboroughLbl: Label 'Gainsborough', MaxLength = 30;
        LiverpoolLbl: Label 'Liverpool', MaxLength = 30;
        LeicesterLbl: Label 'Leicester', MaxLength = 30;
        RhylLbl: Label 'Rhyl', MaxLength = 30;
        LincolnLbl: Label 'Lincoln', MaxLength = 30;
        LutonLbl: Label 'Luton', MaxLength = 30;
        ManchesterLbl: Label 'Manchester', MaxLength = 30;
        MaidstoneLbl: Label 'Maidstone', MaxLength = 30;
        BletchleyLbl: Label 'Bletchley', MaxLength = 30;
        BedfordLbl: Label 'Bedford', MaxLength = 30;
        LondonLbl: Label 'London', MaxLength = 30;
        NewcastleLbl: Label 'Newcastle', MaxLength = 30;
        NewportLbl: Label 'Newport', MaxLength = 30;
        CheddingtonLbl: Label 'Cheddington', MaxLength = 30;
        PeterboroughLbl: Label 'Peterborough', MaxLength = 30;
        KingsLynnLbl: Label 'Kings Lynn', MaxLength = 30;
        PlymouthLbl: Label 'Plymouth', MaxLength = 30;
        SouthseaPortsmouthLbl: Label 'Southsea, Portsmouth', MaxLength = 30;
        PortsmouthLbl: Label 'Portsmouth', MaxLength = 30;
        SwanseaLbl: Label 'Swansea', MaxLength = 30;
        StratfordLbl: Label 'Stratford', MaxLength = 30;
        MacclesfieldLbl: Label 'Macclesfield', MaxLength = 30;
        NewquayLbl: Label 'Newquay', MaxLength = 30;
        AshfordLbl: Label 'Ashford', MaxLength = 30;
        BrixhamLbl: Label 'Brixham', MaxLength = 30;
        WestEndLaneLbl: Label 'West End Lane', MaxLength = 30;
        WatfordLbl: Label 'Watford', MaxLength = 30;
        BorehamwoodLbl: Label 'Borehamwood', MaxLength = 30;

}