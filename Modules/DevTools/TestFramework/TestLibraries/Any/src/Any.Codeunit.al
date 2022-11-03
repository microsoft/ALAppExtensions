// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This library should be used to generate Pseudo-random values for tests
/// This approach is needed to ensure that it is possible to reproduce the failures, since tests will be using the same values
/// To ensure that there are no cross test dependencies, this library must be added as a local variable to the test method
/// </summary>
codeunit 130500 "Any"
{
    var
        Seed: Integer;
        SeedSet: Boolean;

    /// <summary>
    /// Provides an integer between 1 and the given value
    /// </summary>
    /// <param name="MaxValue">Upper value for the number, if the number is negative 1 is returned.</param>
    /// <returns>Pseudo-random integer value</returns>
    procedure IntegerInRange(MaxValue: Integer): Integer
    begin
        if MaxValue < 1 then
            exit(1);

        exit(GetNextValue(MaxValue));
    end;

    /// <summary>
    /// Provides an integer between the given values
    /// </summary>
    /// <param name="MinValue">Lower value for the number</param>
    /// <param name="MaxValue">Upper value for the number</param>
    /// <returns>Pseudo-random integer value</returns>
    procedure IntegerInRange(MinValue: Integer; MaxValue: Integer): Integer
    begin
        exit(MinValue - 1 + GetNextValue(MaxValue - MinValue + 1));
    end;

    /// <summary>
    /// Provides a decimal between the given values
    /// </summary>
    /// <param name="MaxValue">Upper value for the number</param>
    /// <param name="DecimalPlaces">Number of decimal places</param>
    /// <returns>Pseudo-random decimal value</returns>
    procedure DecimalInRange(MaxValue: Integer; DecimalPlaces: Integer): Decimal
    var
        PseudoRandomInteger: Integer;
        Pow: Integer;
    begin
        Pow := Power(10, DecimalPlaces);

        PseudoRandomInteger := IntegerInRange(MaxValue * Pow);

        if PseudoRandomInteger = 0 then
            PseudoRandomInteger := 1
        else
            if PseudoRandomInteger mod 10 = 0 then
                PseudoRandomInteger -= IntegerInRange(1, 9);

        exit(PseudoRandomInteger / Pow);
    end;

    /// <summary>
    /// Provides a decimal between the given values
    /// </summary>
    /// <param name="MinValue">Lower value for the number</param>
    /// <param name="MaxValue">Upper value for the number</param>
    /// <param name="DecimalPlaces">Number of decimal places</param>
    /// <returns>Pseudo-random decimal value</returns>
    procedure DecimalInRange(MinValue: Integer; MaxValue: Integer; DecimalPlaces: Integer): Decimal
    begin
        exit(MinValue + DecimalInRange(MaxValue - MinValue, DecimalPlaces));
    end;

    /// <summary>
    /// Provides a decimal between the given values
    /// </summary>
    /// <param name="MinValue">Lower value for the number</param>
    /// <param name="MaxValue">Upper value for the number</param>
    /// <param name="DecimalPlaces">Number of decimal places</param>
    /// <returns>Pseudo-random decimal value</returns>
    procedure DecimalInRange(MinValue: Decimal; MaxValue: Decimal; DecimalPlaces: Integer): Decimal
    var
        Min: Integer;
        Max: Integer;
        Pow: Integer;
    begin
        Pow := Power(10, DecimalPlaces);
        Min := Round(MinValue * Pow, 1, '>');
        Max := Round(MaxValue * Pow, 1, '<');
        exit(IntegerInRange(Min, Max) / Pow);
    end;

    /// <summary>
    /// Provides a date between current Workdate to <see cref="MaxNumberOfDays"/> of days
    /// </summary>
    /// <param name="MaxNumberOfDays">Max number of days for date</param>
    /// <returns>Pseudo-random Date in range</returns>
    procedure DateInRange(MaxNumberOfDays: Integer): Date
    begin
        exit(DateInRange(WorkDate(), 0, MaxNumberOfDays));
    end;

    /// <summary>
    /// Provides a date between <see cref="StartingDate"/> to <see cref="MaxNumberOfDays"/> of days
    /// </summary>
    /// <param name="StartingDate">Date to calculate the values from</param>
    /// <param name="MaxNumberOfDays">Max number of days for date</param>
    /// <returns>Pseudo-random Date in range</returns>
    procedure DateInRange(StartingDate: Date; MaxNumberOfDays: Integer): Date
    begin
        exit(DateInRange(StartingDate, 0, MaxNumberOfDays));
    end;

    /// <summary>
    /// Provides a date between <see cref="StartingDate"/> + <see cref="MinNumberOfDays"/> to <see cref="MaxNumberOfDays"/> of days
    /// </summary>
    /// <param name="StartingDate">Date to calculate the values from</param>
    /// <param name="MaxNumberOfDays">Max number of days from the StartingDate</param>
    /// <param name="MinNumberOfDays">Minimum number of days from the StartingDate</param>
    /// <returns>Pseudo-random Date in range</returns>
    procedure DateInRange(StartingDate: Date; MinNumberOfDays: Integer; MaxNumberOfDays: Integer): Date
    begin
        if MinNumberOfDays >= MaxNumberOfDays then
            exit(StartingDate);

#pragma warning disable AA0217
        exit(CalcDate(StrSubstNo('<+%1D>', IntegerInRange(MinNumberOfDays, MaxNumberOfDays)), StartingDate));
#pragma warning restore
    end;

    /// <summary>
    /// Provides an alphabetic text
    /// </summary>
    /// <param name="Length">Desired length of the text</param>
    /// <returns>Pseudo-random alphabetic text</returns>
    procedure AlphabeticText(Length: Integer): Text
    var
        ASCIICodeFrom: Integer;
        ASCIICodeTo: Integer;
        Number: Integer;
        i: Integer;
        TextValue: Text;
    begin
        ASCIICodeFrom := 97;
        ASCIICodeTo := 122;

        for i := 1 to Length do begin
            Number := IntegerInRange(ASCIICodeFrom, ASCIICodeTo);
            TextValue[i] := Number;
        end;

        exit(TextValue);
    end;

    /// <summary>
    /// Provides an alphanumeric text
    /// </summary>
    /// <param name="Length">Desired length of the text</param>
    /// <returns>A pseudo-random alphanumeric text</returns>
    procedure AlphanumericText(Length: Integer): Text
    var
        GuidTxt: Text;
    begin
        while StrLen(GuidTxt) < Length do
            GuidTxt += LowerCase(DelChr(Format(GuidValue()), '=', '{}-'));
        exit(CopyStr(GuidTxt, 1, Length));
    end;

    /// <summary>
    /// Provides a Unicode text
    /// </summary>
    /// <param name="Length">Desired length of the text</param>
    /// <returns>Pseudo-random Unicode text</returns>
    procedure UnicodeText(Length: Integer) String: Text
    var
        i: Integer;
    begin
        for i := 1 to Length do
            String[i] := IntegerInRange(1072, 1103); // Cyrillic alphabet (to guarantee only printable chars)

        exit(String)
    end;


    /// <summary>
    /// Provides an Email
    /// </summary>
    /// <returns>Pseudo-random Email</returns>
    procedure Email(): Text
    begin
        exit(Email(20, 20));
    end;

    /// <summary>
    /// Provides an Email
    /// </summary>
    /// <param name="LocalPartLength">Desired length of the local-part</param>
    /// <param name="DomainLength">Desired length of the domain</param>
    /// <returns>Pseudo-random Email text</returns>
    procedure Email(LocalPartLength: Integer; DomainLength: Integer): Text
    begin
        exit(AlphaNumericText(LocalPartLength) + '@' + AlphabeticText(DomainLength) + '.' + AlphabeticText(3));
    end;

    /// <summary>
    /// Provides a Guid
    /// Guid is not pseduo-random, it is random value
    /// </summary>
    /// <returns>Random Guid</returns>
    procedure GuidValue(): Guid
    begin
        exit(CreateGuid());
    end;

    /// <summary>.
    /// Sets the Seed for Pseudo-random number generation.
    /// Setting this value will change the numbers returned.
    /// </summary>
    /// <param name="NewSeed">New seed to be used.</param>
    procedure SetSeed(NewSeed: Integer)
    begin
        Seed := NewSeed;
        SeedSet := true;
        Randomize(Seed);
    end;

    /// <summary>.
    /// Sets the default Seed for Pseudo-random number generation (no. of milliseconds since midnight of today).
    /// Setting this value will change the numbers returned.
    /// </summary>
    procedure SetDefaultSeed()
    begin
        SeedSet := true;
        Randomize();
    end;

    /// <summary>.
    /// This function must be called from all functions that want to use Pseudo-random generation.
    /// This function will call the SetSeed with the default value to ensure the same numbers are returned
    /// </summary>
    /// <param name="MaxValue">Upper range for the number</param>
    /// <returns>Pseudo-random integer value</returns>
    local procedure GetNextValue(MaxValue: Integer): Integer
    begin
        if (not SeedSet) then
            SetSeed(1);

        exit(Random(MaxValue));
    end;
}