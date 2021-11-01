codeunit 137122 "Time Zone Selection Tests"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    [HandlerFunctions('TimeZoneLookupModalPageHandler')]
    procedure TestTimeZoneLookup()
    var
        TimeZoneSelection: Codeunit "Time Zone Selection";
        TimeZone: Text[180];
    begin
        PermissionsMock.Set('Time Zone Read');

        // Exercise
        TimeZoneSelection.LookupTimeZone(TimeZone);

        // Verify
        Assert.AreEqual('Mountain Standard Time', TimeZone,
          'Wrong Time Zone returned from Lookup');
    end;

    [Test]
    procedure TestTimeZoneValidatePartialNext()
    var
        TimeZoneSelection: Codeunit "Time Zone Selection";
        TimeZoneText: Text[180];
    begin
        PermissionsMock.Set('Time Zone Read');

        // Exercise
        TimeZoneText := 'Mountain Standard Time (';
        TimeZoneSelection.ValidateTimeZone(TimeZoneText);

        // Verify
        Assert.AreEqual('Mountain Standard Time (Mexico)', TimeZoneText,
          'Wrong Time Zone returned from Validate');
    end;

    [Test]
    procedure TestTimeZoneValidatePartialPrev()
    var
        TimeZoneSelection: Codeunit "Time Zone Selection";
        TimeZoneText: Text[180];
    begin
        PermissionsMock.Set('Time Zone Read');

        // Exercise
        TimeZoneText := 'Mountain Standard';
        TimeZoneSelection.ValidateTimeZone(TimeZoneText);

        // Verify
        Assert.AreEqual('US Mountain Standard Time', TimeZoneText,
          'Wrong Time Zone returned from Validate');
    end;

    [Test]
    procedure TestTimeZoneValidateFail()
    var
        TimeZoneSelection: Codeunit "Time Zone Selection";
        TimeZoneText: Text[180];
    begin
        PermissionsMock.Set('Time Zone Read');

        // Exercise
        TimeZoneText := 'dummyvalue';
        asserterror TimeZoneSelection.ValidateTimeZone(TimeZoneText);

        // Verify
        Assert.ExpectedError('The Time Zone does not exist');
    end;

    [Test]
    procedure TimeZoneGetDisplayName()
    var
        TimeZoneSelection: Codeunit "Time Zone Selection";
        DisplayName: Text;
    begin
        PermissionsMock.Set('Time Zone Read');

        // Exercise
        DisplayName := TimeZoneSelection.GetTimeZoneDisplayName('Mountain Standard Time (Mexico)');

        // Verify
        Assert.AreEqual('(UTC-07:00) Chihuahua, La Paz, Mazatlan', DisplayName,
          'Wrong Time Zone returned from Validate');

        // Exercise
        DisplayName := TimeZoneSelection.GetTimeZoneDisplayName('Mountain Standard');

        // Verify
        Assert.AreEqual('(UTC-07:00) Arizona', DisplayName,
          'Wrong Time Zone returned from Validate');

        // Exercise
        DisplayName := TimeZoneSelection.GetTimeZoneDisplayName('Romance Standard Time');

        // Verify
        Assert.AreEqual('(UTC+01:00) Brussels, Copenhagen, Madrid, Paris', DisplayName,
          'Wrong Time Zone returned from Validate');
    end;


    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure TimeZoneLookupModalPageHandler(var TimeZonesLookup: TestPage "Time Zones Lookup")
    var
        TimeZone: Record "Time Zone";
    begin
#pragma warning disable AA0210
        TimeZone.SetRange(ID, 'Mountain Standard Time');
#pragma warning restore
        TimeZone.FindFirst();
        TimeZonesLookup.GotoRecord(TimeZone);
        TimeZonesLookup.OK().Invoke();
    end;

}