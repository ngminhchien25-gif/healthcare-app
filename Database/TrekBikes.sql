CREATE DATABASE TrekBikes;
GO
USE TrekBikes;
GO

CREATE TABLE Category(
    CategoryId SMALLINT NOT NULL PRIMARY KEY IDENTITY(1,1),
    CategoryName NVARCHAR(64) NOT NULL,
    Title NVARCHAR(128) NOT NULL,
    Description NVARCHAR(1024) NOT NULL,
    Icon VARCHAR(16) NOT NULL
);
GO
SET IDENTITY_INSERT Category ON;
INSERT INTO Category (CategoryId, CategoryName, Title, Description, Icon) VALUES
(
    1,
    'Road',
    'Trek Road Bikes – Fast and Lightweight Road Bicycles',
    'Explore Trek road bikes designed for speed, efficiency, and long-distance cycling. Find lightweight road bicycles for racing, fitness riding, commuting, and experienced cyclists looking for a smooth and fast ride.',
    'road.png'),
(
    2,
    'City',
    'Trek City Bikes – Comfortable Bikes for Urban Riding',
    'Discover Trek city bikes built for comfortable and practical urban cycling. Perfect for commuting, everyday transportation, recreational rides, and getting around the city with a smooth and reliable bicycle.',
    'city.png'
),
(
    3,
    'Mountain',
    'Trek Mountain Bikes – MTB Bikes for Trails and Off-Road Riding',
    'Explore Trek mountain bikes designed for trail riding, off-road adventures, and challenging terrain. Choose a durable MTB with reliable handling and performance for mountain trails, gravel paths, and outdoor cycling.',
    'mountain.png'
);
GO
SET IDENTITY_INSERT Category OFF;
--DROP TABLE SubCategory;
GO
CREATE TABLE SubCategory(
    SubCategoryId SMALLINT NOT NULL PRIMARY KEY IDENTITY(1, 1),
    CategoryId SMALLINT NOT NULL REFERENCES Category(CategoryId),
    SubCategoryName NVARCHAR(64) NOT NULL,
    Title NVARCHAR(128) NOT NULL,
    Description NVARCHAR(1024) NOT NULL,
    ImageUrl NVARCHAR(32) NOT NULL
);
GO
SET IDENTITY_INSERT SubCategory ON;
INSERT INTO SubCategory (SubCategoryId, CategoryId, SubCategoryName, Title, Description, ImageUrl) VALUES
    (1, 1, 'Madone Carbon', 'Madone Road Bikes Explained: Fast & Lightweight', 'Ride faster with Trek Madone road bikes combining advanced aerodynamics, responsive handling and all-day comfort.', 'madone-carbon.png'),
    (2, 1, 'Domane Carbon', 'Domane Bikes Online | All Domane Models Collection', 'Browse Trek Domane road bikes with road-smoothing tech and endurance design. Explore models built for speed, comfort, and versatility.', 'domane-carbon.png'),
    (3, 1, 'Domane AL', 'Domane AL all-road aluminum bikes – Trek Bikes', 'Domane AL is a versatile and affordable road bike that&rsquo;s made for long endurance rides, pacelines, and light gravel. See the bike online and in-store.', 'domane-al.png'),
    
    (4, 2, 'FX sport', 'FX Sport carbon fitness bike – Trek Bikes', 'FX Sport is a carbon fitness bike built for performance on or off the pavement. Ride with confidence on roads, unpaved trails, gravel, and more. Shop now.', 'trek-fx-sport.png'),
    (5, 2, 'FX', 'FX lightweight hybrid bike – Trek Bikes', 'FX is a lightweight hybrid bike made for riders who want one bike for fitness, commuting, and everyday speed. Shop now.', 'trek-fx.png'),
    
    (6, 3, 'Fuel', 'Shop Fuel – The adaptable trail bike', 'Want an adaptable trail MTB built for big climbs, fast descents, and everything in between? Fuel delivers three setups and endless ways to ride', 'fuel.png'),
    (7, 3, 'Fuel+', 'Shop Fuel+ - The adaptable mid-power trail e-MTB', 'Looking for a trail MTB with natural-feeling assist and a dialed fit for any ride style? Fuel+ delivers three setups and endless versatility.', 'fuel-plus.png'),
    (8, 3, 'Slash', 'Slash Bikes Online | Slash Enduro MTB for Long Travel', 'Ride Trek Slash, an enduro mountain bike built for aggressive descents and tough climbs. Fast, capable and ready for any trail.', 'slash.png'),
    (9, 3, 'Slash+', 'Lap it up with Trek’s lightweight enduro e-bike – Slash+', 'Chase down long days and extra laps on Slash+. Capable, quiet, and with tons of travel, it&rsquo;s the lightweight enduro e-MTB ready for anything. Shop now!', 'slash-plus.png'),
    (10, 3, 'Rail+', 'Shop for Rail+ eMTB | Rail+ Electric Mountain Bike Collection', 'Browse Trek Rail+ electric mountain bikes. Full-powered enduro e-MTBs built for range, speed and control on rugged terrain.', 'rail-plus.png');
SET IDENTITY_INSERT SubCategory OFF;




--DROP TABLE Bike;
GO

CREATE TABLE Bike(
    BikeId INT NOT NULL PRIMARY KEY IDENTITY(1, 1),
    SubCategoryId SMALLINT NOT NULL REFERENCES SubCategory(SubCategoryId),
    BikeName NVARCHAR(128) NOT NULL,
    ImageUrl VARCHAR(32) NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    Frame NVARCHAR(64),
    Weight NVARCHAR(128),
    Drivetrain NVARCHAR(64),
    Wheels NVARCHAR(64),
    Fork NVARCHAR(64),
    RearShock NVARCHAR(64),
    Tires NVARCHAR(64),
    Brakes NVARCHAR(64) 
);
GO
--TRUNCATE TABLE Bike;
GO
SET IDENTITY_INSERT Bike ON;
INSERT INTO Bike (BikeId, SubCategoryId, BikeName, Price, ImageUrl, Frame, Weight, Drivetrain, Wheels) VALUES
    (5339362, 1, 'Madone SLR 9 AXS Gen 8', 13499.99, 'madone-slr-9-axs-gen-8.png', '900 Series OCLV Carbon', 'ML - 7.00 kg / 15.44 lbs', 'SRAM RED AXS E1, 2x12, power meter', 'Bontrager Aeolus RSL 51, OCLV Carbon'),
    (5339146, 1, 'Madone SLR 7 AXS Gen 8', 9499.99, 'madone-slr-7-axs-gen-8.png', '900 Series OCLV Carbon', 'ML - 7.22 kg / 15.92 lbs', 'SRAM Force AXS E1, 2x12, power meter', 'Bontrager Aeolus Pro 51, OCLV Carbon'),
    (5344411, 1, 'Madone SLR 9 AXS 1x Gen 8', 12999.99, 'madone-slr-9-axs-1x-gen-8.png', '900 Series OCLV Carbon', 'ML - 6.40 kg / 14.11 lbs', 'SRAM RED AXS E1, 1x12', 'Bontrager Aeolus RSL 37, OCLV Carbon'),
    (5339290, 1, 'Madone SLR 9 Gen 8', 12899.99, 'madone-slr-9-gen-8.png', '900 Series OCLV Carbon', 'ML - 7.05 kg / 15.55 lbs (with TLR sealant, no tubes, no bottles/cages)', 'Shimano Dura-Ace Di2, 2x12', 'Bontrager Aeolus RSL 51, OCLV Carbon'),
    (5337861, 1, 'Madone SL 5 Gen 8', 2999.99, 'madone-sl-5-gen-8.png', '500 Series OCLV Carbon', 'ML - 8.64 kg / 19.05 lbs', 'Shimano 105, 2x12', 'Bontrager Paradigm 23, alloy'),
    (5337997, 1, 'Madone SL 6 AXS Gen 8', 4999.99, 'madone-sl-6-axs-gen-8.png', '500 Series OCLV Carbon', 'ML - 8.11 kg / 17.88 lbs', 'SRAM Rival AXS E1, 2x12', 'Bontrager Aeolus Elite 50, OCLV Carbon'),
    (5337943, 1, 'Madone SL 6 Gen 8', 5299.99, 'madone-sl-6-gen-8.png', '500 Series OCLV Carbon', 'ML - 8.16 kg / 17.99 lbs', 'Shimano 105 Di2, 2x12', 'Bontrager Aeolus Elite 50, OCLV Carbon'),
    (5338023, 1, 'Madone SL 7 Gen 8', 5999.99, 'madone-sl-7-gen-8.png', '500 Series OCLV Carbon', 'ML - 7.87 kg / 17.36 lbs', 'Shimano Ultegra Di2, 2x12', 'Bontrager Aeolus Pro 51, OCLV Carbon'),
    (5339074, 1, 'Madone SLR 7 Gen 8', 8999.99, 'madone-slr-7-gen-8.png', '900 Series OCLV Carbon', 'ML - 7.52 kg / 16.58 lbs (with TLR sealant, no tubes, no bottles/cages)', 'Shimano Ultegra Di2, 2x12', 'Bontrager Aeolus Pro 51, OCLV Carbon'),
    (5352731, 2, 'Domane SLR 9 AXS No. 76 Gen 5', 14499.99, 'domane-slr-9-axs-no-76-gen-5.png', '900 Series OCLV Carbon', 'ML - 7.19 kg / 15.86 lbs (with tubes)', 'SRAM RED AXS, 2x12, power meter', 'Bontrager Aeolus RSL 37, OCLV Carbon'),
    (5350058, 2, 'Domane SLR 9 AXS Gen 5', 11499.99, 'domane-slr-9-axs-no-76-gen-5.png', '900 Series OCLV Carbon', 'ML - 7.29 kg / 16.08 lbs (with tubes)', 'SRAM RED AXS, 2x12, power meter', 'Bontrager Aeolus RSL 51, OCLV Carbon'),
    (5350527, 2, 'Domane SLR 9 AXS 1x Gen 5', 11499.99, 'domane-slr-9-axs-1x-gen-5.png', '900 Series OCLV Carbon', 'ML - 6.63 kg / 14.62 lbs (with tubes)', 'SRAM RED AXS, 1x13, power meter', 'Bontrager Aeolus RSL 37, OCLV Carbon'),
    (5349962, 2, 'Domane SLR 9 Gen 5', 10999.99, 'domane-slr-9-gen-5.png', '900 Series OCLV Carbon', 'ML - 7.34 kg / 16.19 lbs (with tubes)', 'Shimano Dura-Ace Di2, 2x12', 'Bontrager Aeolus RSL 51, OCLV Carbon'),
    (5350776, 3, 'Domane AL 5 Gen 4', 1999.99, 'domane-al-5-gen-4.png', 'Alpha 100 Aluminum', '56 - 9.80 kg / 21.61 lbs', 'Shimano 105, 2x12', 'Bontrager Paradigm 23, alloy'),
    (5350575, 3, 'Domane AL 2 Gen 4', 1199.99, 'domane-al-2-gen-4.png', 'Alpha 100 Aluminum', '56 - 10.35 kg / 22.82 lbs', 'Shimano Claris, 2x8', 'Bontrager Paradigm 23, alloy'),
    (5345591, 3, 'Domane AL 4 Gen 4', 1599.99, 'domane-al-4-gen-4.png', 'Alpha 100 Aluminum', '56 - 10.10 kg / 22.27 lbs', 'Shimano Tiagra, 2x11', 'Bontrager Paradigm 23, alloy'),
    (5339884, 4, 'FX Sport AL 3', 999.99, 'fx-sport-al-3.png', 'Alpha Gold Aluminum', 'M - 11.10 kg / 24.48 lbs', 'Bontrager Girona Comp, 700x42mm', 'Bontrager Girona Comp, 700x42mm'),
    (5323697, 4, 'FX Sport SL 4', 1999.99, 'fx-sport-sl-4.png', '400 Series OCLV Carbon', 'M - 10.50 kg / 23.15 lbs', 'Shimano CUES, 10-speed', 'Bontrager GR1 Expert, 700x40mm'),
    (5323991, 4, 'FX Sport SL 6', 3499.99, 'fx-sport-sl-6.png', '400 Series OCLV Carbon', 'M - 9.50 kg / 20.95 lbs', 'SRAM Apex XPLR AXS, 12-speed', 'Bontrager Girona Pro, 700x42mm'),
    (5348151, 4, 'FX Sport SL 6', 3499.99, 'fx-sport-sl-6.png', '400 Series OCLV Carbon', 'M - 9.80 kg / 21.61 lbs', 'SRAM Apex XPLR AXS, 12-speed', 'Bontrager Girona Pro, 700x42mm'),
    (5348195, 4, 'FX Sport SL 5', 2299.99, 'fx-sport-sl-5.png', '400 Series OCLV Carbon', 'M - 10.60 kg / 23.37 lbs', 'SRAM Apex, 11-speed', 'Bontrager GR1 Expert, 700x40mm'),
    (5348085, 4, 'FX Sport SL 4', 1999.99, 'fx-sport-sl-4-red.png', '400 Series OCLV Carbon', 'M - 10.90 kg / 24.04 lbs', 'Shimano CUES, 10-speed', 'Bontrager GR1 Expert, 700x40mm');

INSERT INTO Bike (BikeId, SubCategoryId, BikeName, Price, ImageUrl, Fork, Brakes, Weight, Drivetrain, Wheels) VALUES
    (5336620, 5, 'FX 1', 649.99, 'fx-1.png', 'Rigid steel', 'Mechanical disc brakes', 'M - 13.00 kg / 28.67 lbs', 'Shimano Acera, 8-speed', 'Bontrager 700x35mm'),
    (5336668, 5, 'FX 2', 799.99, 'fx-2.png', 'Rigid steel', 'Mechanical disc brakes', 'M - 12.10 kg / 26.68 lbs', 'Shimano CUES, 9-speed', 'Bontrager 700x35mm'),
    (5336698, 5, 'FX 2 Midstep', 799.99, 'fx-2-midstep.png', 'Rigid alloy', 'Hydraulic disc brakes', ' M - 11.95 kg / 26.35 lbs', 'Shimano CUES, 9-speed', 'Bontrager 700x35mm');

INSERT INTO Bike (BikeId, SubCategoryId, BikeName, Price, ImageUrl, Frame, Fork, RearShock, Wheels) VALUES
    (5351707, 6, 'Fuel LX 9.8 Eagle 90 Gen 7', 6699.99, 'fuel-lx-9-9-x0-axs-gen-7.png', 'OCLV Mountain Carbon', 'Rockshox ZEB Ultimate B1, 170mm', 'RockShox Vivid Ultimate D1', 'Bontrager Line Comp 30'),
    (5351879, 6, 'Fuel MX 9.9 X0 AXS Gen 7', 8999.99, 'fuel-mx-9-9-x0-axs-gen-7.png', 'OCLV Mountain Carbon', 'RockShox Vivid Ultimate D1', 'RockShox Vivid Ultimate D1', 'Bontrager Line Pro 30'),
    (5333379, 6, 'Fuel EX 9.9 X0 AXS Gen 7', 8499.99, 'fuel-ex-9-9-x0-axs-gen-7.png', 'OCLV Mountain Carbon, 145mm', 'Lyrik Ultimate, 150mm', 'RockShox Deluxe Ultimate RC2T', 'Bontrager Line Pro 30'),
    (5348980, 6, 'Fuel EX 9.9 X0 AXS Gen 7', 8499.99, 'fuel-ex-9-9-x0-axs-gen-7.png', 'OCLV Mountain Carbon, 145mm', 'Fork RockShox Lyrik Ultimate, 150mm', 'RockShox Deluxe Ultimate RC2T', 'Bontrager Line Pro 30'),
    (5341004, 7, 'Fuel+ LX 9.8 Eagle 90 Gen 2', 8699.97, 'fuel+-lx-9-8-eagle-90-gen-2.png', 'OCLV Mountain Carbon, 160mm', 'Fox Factory 38, 170mm', 'shock Fox DHX2, coil', 'Bontrager Line Comp 30'),
    (5340808, 7, 'Fuel+ LX 9.8 Eagle 90 Gen 2', 8199.97, 'fuel+-ex-9-8-eagle-90-gen-2.png', 'OCLV Mountain Carbon, 145mm', 'RockShox Lyrik Ultimate, 150mm', 'RockShox Deluxe Ultimate RC2T', 'Bontrager Line Comp 30'),
    (5333332, 8, 'Slash 9.9 X0 AXS T-Type Gen 6', 7799.93, 'fuel+-ex-9-8-eagle-90-gen-2.png', 'OCLV Mountain Carbon, 170mm', 'RockShox ZEB Ultimate, 170mm', 'RockShox Vivid Ultimate', 'Bontrager Line Comp 30'),
    (5333251, 8, 'Slash 9.8 XT Di2 Gen 6', 5999.93, 'slash-9-9-x0-axs-gen-6.png', 'OCLV Mountain Carbon, 170mm', 'RockShox ZEB Select+, 170mm', 'RockShox Vivid Select+', 'Bontrager Line Comp 30'),
    (5337464, 9, 'Slash+ 9.7', 7999.93, 'slash+-9-7.png', 'OCLV Mountain Carbon, 170mm', 'Fox Rhythm 38, 170mm', 'Fox Performance Float X', 'Bontrager Line Comp 30'),
    (5337753, 9, 'Slash+ 9.9', 10499.93, 'slash+-9-9.png', 'OCLV Mountain Carbon, 170mm', 'RockShox ZEB Ultimate, 170mm', 'RockShox Vivid Ultimate', 'Bontrager Line Comp 30'),
    (5328981, 10, 'Rail+ 9.8 GX AXS T-Type Gen 5', 8499.93, 'rail+-9-8-gx-axs-gen-5.png', 'OCLV Mountain Carbon, 160mm', 'For Performance Elite Float 38, 160mm', 'Fox Performance Elite Float X', 'Bontrager Line Comp 30'),
    (5348379, 10, 'Rail+ 8 Gen 5', 5999.93, 'rail-8-gen-5.png', 'Alpha Platinum Aluminum, 160mm', 'RockShox Lyrik, 160mm', 'RockShox Super Deluxe', 'Bontrager Line TLR 30');
SET IDENTITY_INSERT Bike OFF;

--DROP PROC DeleteCategory;
GO
CREATE PROC DeleteCategory(
	@Id SMALLINT
)
AS
	IF NOT EXISTS(SELECT * FROM SubCategory WHERE CategoryId = @Id)
		DELETE FROM Category WHERE CategoryId = @Id;
GO
Drop Table Member;
GO
CREATE TABLE Member(
    MemberId NVARCHAR(32) NOT NULL PRIMARY KEY,
    GivenName NVARCHAR(16) NOT NULL,
    Surname NVARCHAR(16),
    Email NVARCHAR(64) NOT NULL UNIQUE,
	Password NVARCHAR(128) NOT NULL,
    Role SMALLINT NOT NULL DEFAULT 0
);
GO

CREATE PROC AddMember(
    @MemberId NVARCHAR(32),
    @GivenName NVARCHAR(16),
    @Surname NVARCHAR(16),
    @Email NVARCHAR(64),
	@Password NVARCHAR(128),
    @Role SMALLINT
)
AS
    IF NOT EXISTS(SELECT * FROM Member WHERE MemberId = @MemberId OR Email = @Email)
        INSERT INTO Member(MemberId, GivenName, Surname, Email, Password, Role) VALUES
        (@MemberId, @GivenName, @Surname, @Email, @Password, @Role);
GO
select * from Member;