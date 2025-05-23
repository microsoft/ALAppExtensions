// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Foundation;

using Microsoft.DemoTool.Helpers;

codeunit 19055 "Create IN Post Code"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoINPostCode: Codeunit "Contoso IN Post Code";
    begin
        ContosoINPostCode.SetOverwriteData(true);
        ContosoINPostCode.InsertPostCode('IN-110001', 'NEW DELHI', 'IN');
        ContosoINPostCode.InsertPostCode('IN-122002', 'GURUGRAM', 'IN');
        ContosoINPostCode.InsertPostCode('110001', 'New Delhi', 'IN');
        ContosoINPostCode.InsertPostCode('110002', 'New Delhi', 'IN');
        ContosoINPostCode.InsertPostCode('110003', 'New Delhi', 'IN');
        ContosoINPostCode.InsertPostCode('110004', 'New Delhi', 'IN');
        ContosoINPostCode.InsertPostCode('110005', 'New Delhi', 'IN');
        ContosoINPostCode.InsertPostCode('110075', 'New Delhi', 'IN');
        ContosoINPostCode.InsertPostCode('121006', 'Faridabad', 'IN');
        ContosoINPostCode.InsertPostCode('122001', 'Gurugram', 'IN');
        ContosoINPostCode.InsertPostCode('122002', 'Gurugram', 'IN');
        ContosoINPostCode.InsertPostCode('201309', 'Noida', 'IN');
        ContosoINPostCode.InsertPostCode('400001', 'Mumbai', 'IN');
        ContosoINPostCode.InsertPostCode('440001', 'Nagpur', 'IN');
        ContosoINPostCode.InsertPostCode('560001', 'Bengaluru', 'IN');
        ContosoINPostCode.InsertPostCode('600001', 'Chennai', 'IN');
        ContosoINPostCode.InsertPostCode('700001', 'Kolkata', 'IN');
        ContosoINPostCode.InsertPostCode('GB-B27 4KT', 'Birmingham', 'GB');
        ContosoINPostCode.InsertPostCode('GB-B31 2AL', 'Birmingham', 'GB');
        ContosoINPostCode.InsertPostCode('GB-B32 4TF', 'Sparkhill, Birmingham', 'GB');
        ContosoINPostCode.InsertPostCode('GB-B68 5TT', 'Bromsgrove', 'GB');
        ContosoINPostCode.InsertPostCode('GB-BA24 6KS', 'Bath', 'GB');
        ContosoINPostCode.InsertPostCode('GB-BR1 2ES', 'Bromley', 'GB');
        ContosoINPostCode.InsertPostCode('GB-BS3 6KL', 'Bristol', 'GB');
        ContosoINPostCode.InsertPostCode('GB-CB1 2FB', 'Cambridge', 'GB');
        ContosoINPostCode.InsertPostCode('GB-CB3 7GG', 'Cambridge', 'GB');
        ContosoINPostCode.InsertPostCode('GB-CF22 1XU', 'Cardiff', 'GB');
        ContosoINPostCode.InsertPostCode('GB-CT6 21ND', 'Hythe', 'GB');
        ContosoINPostCode.InsertPostCode('GB-CV6 1GY', 'Coventry', 'GB');
        ContosoINPostCode.InsertPostCode('GB-CV9 3QN', 'Atherstone', 'GB');
        ContosoINPostCode.InsertPostCode('GB-DA5 3EF', 'Sidcup', 'GB');
        ContosoINPostCode.InsertPostCode('GB-DY5 4DJ', 'Dudley', 'GB');
        ContosoINPostCode.InsertPostCode('GB-E12 5TG', 'Edinburgh', 'GB');
        ContosoINPostCode.InsertPostCode('GB-EC2A 3JL', 'London', 'GB');
        ContosoINPostCode.InsertPostCode('GB-EH1 3EG', 'Edinburgh', 'GB');
        ContosoINPostCode.InsertPostCode('GB-EH16 8JS', 'Edinburgh', 'GB');
        ContosoINPostCode.InsertPostCode('GB-GL1 9HM', 'Gloucester', 'GB');
        ContosoINPostCode.InsertPostCode('GB-GL50 1TY', 'Cheltenham', 'GB');
        ContosoINPostCode.InsertPostCode('GB-GL78 5TT', 'Cheltenham', 'GB');
        ContosoINPostCode.InsertPostCode('GB-GU2 7XH', 'Guildford', 'GB');
        ContosoINPostCode.InsertPostCode('GB-GU2 7YQ', 'Guildford', 'GB');
        ContosoINPostCode.InsertPostCode('GB-GU3 2SE', 'Guildford', 'GB');
        ContosoINPostCode.InsertPostCode('GB-GU52 8DY', 'Fleet', 'GB');
        ContosoINPostCode.InsertPostCode('GB-GU7 5GT', 'Guildford', 'GB');
        ContosoINPostCode.InsertPostCode('GB-HG1 7YW', 'Ripon', 'GB');
        ContosoINPostCode.InsertPostCode('GB-HP43 2AY', 'Tring', 'GB');
        ContosoINPostCode.InsertPostCode('GB-IB7 7VN', 'Gainsborough', 'GB');
        ContosoINPostCode.InsertPostCode('GB-L18 6SA', 'Liverpool', 'GB');
        ContosoINPostCode.InsertPostCode('GB-LE16 7YH', 'Leicester', 'GB');
        ContosoINPostCode.InsertPostCode('GB-LL6 5GB', 'Rhyl', 'GB');
        ContosoINPostCode.InsertPostCode('GB-LN23 6GS', 'Lincoln', 'GB');
        ContosoINPostCode.InsertPostCode('GB-LU3 4FY', 'Luton', 'GB');
        ContosoINPostCode.InsertPostCode('GB-M22 5TG', 'Manchester', 'GB');
        ContosoINPostCode.InsertPostCode('GB-M61 2YG', 'Manchester', 'GB');
        ContosoINPostCode.InsertPostCode('GB-ME5 6RL', 'Maidstone', 'GB');
        ContosoINPostCode.InsertPostCode('GB-MK21 7GG', 'Bletchley', 'GB');
        ContosoINPostCode.InsertPostCode('GB-MK41 5AE', 'Bedford', 'GB');
        ContosoINPostCode.InsertPostCode('GB-MO2 4RT', 'Manchester', 'GB');
        ContosoINPostCode.InsertPostCode('GB-N12 5XY', 'London', 'GB');
        ContosoINPostCode.InsertPostCode('GB-N16 34Z', 'London', 'GB');
        ContosoINPostCode.InsertPostCode('GB-NE21 3YG', 'Newcastle', 'GB');
        ContosoINPostCode.InsertPostCode('GB-NP10 8BE', 'Newport', 'GB');
        ContosoINPostCode.InsertPostCode('GB-NP5 6GH', 'Newport', 'GB');
        ContosoINPostCode.InsertPostCode('GB-OX16 0UA', 'Cheddington', 'GB');
        ContosoINPostCode.InsertPostCode('GB-PE17 4RN', 'Cambridge', 'GB');
        ContosoINPostCode.InsertPostCode('GB-PE21 3TG', 'Peterborough', 'GB');
        ContosoINPostCode.InsertPostCode('GB-PE23 5IK', 'Kings Lynn', 'GB');
        ContosoINPostCode.InsertPostCode('GB-PL14 5GB', 'Plymouth', 'GB');
        ContosoINPostCode.InsertPostCode('GB-PO21 6HG', 'Southsea, Portsmouth', 'GB');
        ContosoINPostCode.InsertPostCode('GB-PO7 2HI', 'Portsmouth', 'GB');
        ContosoINPostCode.InsertPostCode('GB-RG6 1WG', 'Reading', 'GB');
        ContosoINPostCode.InsertPostCode('GB-SA1 2HS', 'Swansea', 'GB');
        ContosoINPostCode.InsertPostCode('GB-SA3 7HI', 'Stratford', 'GB');
        ContosoINPostCode.InsertPostCode('GB-SE1 0AX', 'London', 'GB');
        ContosoINPostCode.InsertPostCode('GB-SK21 5DL', 'Macclesfield', 'GB');
        ContosoINPostCode.InsertPostCode('GB-TA3 4FD', 'Newquay', 'GB');
        ContosoINPostCode.InsertPostCode('GB-TN27 6YD', 'Ashford', 'GB');
        ContosoINPostCode.InsertPostCode('GB-TQ17 8HB', 'Brixham', 'GB');
        ContosoINPostCode.InsertPostCode('GB-W1 3AL', 'London', 'GB');
        ContosoINPostCode.InsertPostCode('GB-W2 6BD', 'London', 'GB');
        ContosoINPostCode.InsertPostCode('GB-W2 8HG', 'London', 'GB');
        ContosoINPostCode.InsertPostCode('GB-WC1 2GS', 'West End Lane', 'GB');
        ContosoINPostCode.InsertPostCode('GB-WC1 3DG', 'London', 'GB');
        ContosoINPostCode.InsertPostCode('GB-WD1 6YG', 'Watford', 'GB');
        ContosoINPostCode.InsertPostCode('GB-WD2 4RG', 'Watford', 'GB');
        ContosoINPostCode.InsertPostCode('GB-WD6 8UY', 'Borehamwood', 'GB');
        ContosoINPostCode.InsertPostCode('GB-WD6 9HY', 'Borehamwood', 'GB');
        ContosoINPostCode.InsertPostCode('ZA-0700', 'Polokwane', 'ZA');
        ContosoINPostCode.SetOverwriteData(false);
    end;
}
