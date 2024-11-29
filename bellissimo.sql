CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Enum Definitions
CREATE TYPE ContactType AS ENUM ('PHONE', 'EMAIL');
CREATE TYPE OrderStatus AS ENUM ('PENDING', 'COMPLETED', 'CANCELLED');
CREATE TYPE PaymentMethod AS ENUM ('CREDIT_CARD', 'CASH', 'ONLINE');
CREATE TYPE PaymentStatus AS ENUM ('PAID', 'PENDING');
CREATE TYPE RoleName AS ENUM ('CHEF', 'WAITER', 'MANAGER', 'HOST', 'BARTENDER');
CREATE TYPE AuthRole AS ENUM ('USER', 'ADMIN', 'SUPERADMIN', 'STAFF', 'CUSTOM_ROLE');

-- File Table
CREATE TABLE File (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    filename TEXT NOT NULL,
    originalname TEXT NOT NULL,
    path TEXT NOT NULL,
    mimetype TEXT NOT NULL,
    createdAt TIMESTAMPTZ DEFAULT now(),
    lastEditedAt TIMESTAMPTZ DEFAULT now()
);

-- Auth Table
CREATE TABLE Auth (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    avatar_id UUID REFERENCES File(id) ON DELETE SET NULL,
    password TEXT NOT NULL,
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    phoneNumber TEXT UNIQUE NOT NULL,
    resetToken TEXT,
    resetTokenExpiry TIMESTAMPTZ,
    role AuthRole NOT NULL DEFAULT 'USER',
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- Contact Table
CREATE TABLE Contact (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    authId UUID REFERENCES Auth(id) ON DELETE CASCADE,
    type ContactType NOT NULL,
    value TEXT NOT NULL,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- Address Table
CREATE TABLE Address (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    street TEXT NOT NULL,
    city TEXT NOT NULL,
    state TEXT NOT NULL,
    country TEXT NOT NULL,
    postcode TEXT NOT NULL,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- UserAddress Table
CREATE TABLE UserAddress (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    authId UUID REFERENCES Auth(id) ON DELETE CASCADE,
    addressId UUID REFERENCES Address(id) ON DELETE CASCADE,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- Category Table
CREATE TABLE Category (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    description TEXT,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- Menu Table
CREATE TABLE Menu (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name TEXT NOT NULL,
    file_id UUID REFERENCES File(id) ON DELETE SET NULL,
    description TEXT,
    price NUMERIC CHECK (price >= 0) NOT NULL,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- MenuCategory Table
CREATE TABLE MenuCategory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    menuId UUID REFERENCES Menu(id) ON DELETE CASCADE,
    categoryId UUID REFERENCES Category(id) ON DELETE CASCADE
);

-- Order Table
CREATE TABLE "Order" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    authId UUID REFERENCES Auth(id) ON DELETE SET NULL,
    totalPrice NUMERIC CHECK (totalPrice >= 0) NOT NULL,
    status OrderStatus NOT NULL,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- OrderMenu Table
CREATE TABLE OrderMenu (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    orderId UUID REFERENCES "Order"(id) ON DELETE CASCADE,
    menuId UUID REFERENCES Menu(id) ON DELETE CASCADE,
    quantity INT CHECK (quantity > 0) NOT NULL
);

-- Payment Table
CREATE TABLE Payment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    orderId UUID REFERENCES "Order"(id) ON DELETE SET NULL,
    amount NUMERIC CHECK (amount >= 0) NOT NULL,
    method PaymentMethod NOT NULL,
    status PaymentStatus NOT NULL,
    authId UUID REFERENCES Auth(id) ON DELETE SET NULL,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- Reservation Table
CREATE TABLE Reservation (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    authId UUID REFERENCES Auth(id) ON DELETE SET NULL,
    dateTime TIMESTAMPTZ NOT NULL,
    numGuests INT CHECK (numGuests > 0) NOT NULL,
    specialRequest TEXT,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- Review Table
CREATE TABLE Review (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    authId UUID REFERENCES Auth(id) ON DELETE SET NULL,
    menuId UUID REFERENCES Menu(id) ON DELETE SET NULL,
    rating INT CHECK (rating >= 1 AND rating <= 5) NOT NULL,
    comment TEXT,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- Happenings Table
CREATE TABLE Happenings (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    authId UUID REFERENCES Auth(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    description TEXT,
    date TIMESTAMPTZ NOT NULL,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- Role Table
CREATE TABLE Role (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name RoleName NOT NULL,
    description TEXT,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- Employee Table
CREATE TABLE Employee (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    firstName TEXT NOT NULL,
    lastName TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phoneNumber TEXT UNIQUE NOT NULL,
    roleId UUID REFERENCES Role(id) ON DELETE SET NULL,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);

-- Shift Table
CREATE TABLE Shift (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    employeeId UUID REFERENCES Employee(id) ON DELETE CASCADE,
    startTime TIMESTAMPTZ NOT NULL,
    endTime TIMESTAMPTZ NOT NULL,
    createdAt TIMESTAMPTZ DEFAULT now(),
    updatedAt TIMESTAMPTZ DEFAULT now()
);
