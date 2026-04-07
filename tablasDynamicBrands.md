- Database engine: PostgreSQL 15 
- Database name: DynamicBrandsDB

- Context: 

---

# Tables:

## Users

- userId: INT GENERATED ALWAYS AS IDENTITY (PK)
- fullName: varchar(100) NOT NULL
- documentId: varchar(20) UNIQUE NOT NULL
- createdAt: timestamp NOT NULL

---

## Roles

- roleId: INT GENERATED ALWAYS AS IDENTITY (PK)
- name: varchar(50) NOT NULL

---

## Permissions

- permissionId: INT GENERATED ALWAYS AS IDENTITY (PK)
- name: varchar(50) NOT NULL

---

## RolePermissions

- rolePermissionId: INT GENERATED ALWAYS AS IDENTITY (PK)
- roleId: Int NOT NULL (FK)
- permissionId: Int NOT NULL (FK)

---

## UserRoles

- userRoleId: INT GENERATED ALWAYS AS IDENTITY (PK)
- userId: Int NOT NULL (FK)
- roleId: Int NOT NULL (FK)

---

## ContactTypes

- contactTypeId: INT GENERATED ALWAYS AS IDENTITY (PK)
- name: varchar(20) NOT NULL -- (EMAIL, PHONE, WHATSAPP, EMERGENCY)

---

## Contacts

- contactId: INT GENERATED ALWAYS AS IDENTITY (PK)
- contactTypeId: Int NOT NULL (FK)
- value: varchar(100) NOT NULL

---

## UserContacts

- userContactId: INT GENERATED ALWAYS AS IDENTITY (PK)
- userId: Int NOT NULL (FK)
- contactId: Int NOT NULL (FK)
- isPrimary: boolean

---

## JudicialApiRequests

- requestId: INT GENERATED ALWAYS AS IDENTITY (PK)
- userId: Int NOT NULL (FK)
- requestDate: timestamp NOT NULL
- responseStatus: varchar(20) -- (SUCCESS, ERROR)
- responseCode: int
- responseMessage: varchar(255)

---

## BiometricValidations

- validationId: INT GENERATED ALWAYS AS IDENTITY (PK)
- userId: Int NOT NULL (FK)
- validationDate: timestamp NOT NULL
- status: boolean
- ocrConfidence: decimal
- livenessScore: decimal

---

## States

- stateId: INT GENERATED ALWAYS AS IDENTITY (PK)
- stateName: varchar(20) NOT NULL -- (LIMPIO, CON_ANTECEDENTES)

---

## CriminalRecords

- recordId: INT GENERATED ALWAYS AS IDENTITY (PK)
- userId: Int NOT NULL (FK)
- stateId: Int NOT NULL (FK)
- lastChecked: timestamp NOT NULL

---

## CriminalRecordHistory

- historyId: INT GENERATED ALWAYS AS IDENTITY (PK)
- userId: Int NOT NULL (FK)
- stateId: Int NOT NULL (FK)
- checkedAt: timestamp NOT NULL

---

## Locations

- locationId: INT GENERATED ALWAYS AS IDENTITY (PK)
- userId: Int NOT NULL (FK)
- position: GEOGRAPHY(POINT, 4326) NOT NULL
- recordedAt: timestamp NOT NULL

---

## ActionsOfLogs

- actionOfLogId: INT GENERATED ALWAYS AS IDENTITY (PK)
- actionOfLogName: varchar(50) NOT NULL

---

## SystemLogs

- logId: INT GENERATED ALWAYS AS IDENTITY (PK)
- userId: Int (FK)
- actionOfLogId: Int NOT NULL (FK)
- description: varchar(255)
- createdAt: timestamp NOT NULL

---

## Countries

- countryId: INT GENERATED ALWAYS AS IDENTITY (PK)
- countryName: varchar(50) NOT NULL

---

## Provinces

- provinceId: INT GENERATED ALWAYS AS IDENTITY (PK)
- countryId: Int NOT NULL
- provinceName: varchar(50) NOT NULL

---

## Cantons

- cantonId: INT GENERATED ALWAYS AS IDENTITY (PK)
- provinceId: Int NOT NULL (FK)
- cantonName: varchar(50) NOT NULL

---

## Districts

- districtId: INT GENERATED ALWAYS AS IDENTITY (PK)
- cantonId: Int NOT NULL (FK)
- districtName: varchar(50) NOT NULL

---

## Addresses

- addressId: INT GENERATED ALWAYS AS IDENTITY (PK)
- districtId: Int NOT NULL (FK)
- exactDetail: varchar(255) NOT NULL 
- latitude: decimal
- longitude: decimal

---

## TypesOfAddresses

- typeOfAddressId: INT GENERATED ALWAYS AS IDENTITY (PK)
- typeOfAddressName: varchar(20) -- (HOME, WORK, OTHER)

---

## UserAddresses

- userAddressId: INT GENERATED ALWAYS AS IDENTITY (PK)
- userId: Int NOT NULL (FK)
- addressId: Int NOT NULL (FK)
- typeOfAddressId: Int NOT NULL (FK)

---

# Sample Data (Testing)

## Roles

roleId	name
1	ADMIN
2	SECURITY_AGENT
3	USER

---

## Permissions

permissionId	name
1	VIEW_USERS
2	VALIDATE_USER
3	VIEW_REPORTS
4	MANAGE_SYSTEM

---

## RolePermissions

rolePermissionId	roleId	permissionId
1	1	1
2	1	2
3	1	3
4	1	4
5	2	2
6	2	3
7	3	1

---

## UserRoles

userRoleId	userId	roleId
1	1	ADMIN
2	2	USER
3	3	SECURITY_AGENT

---

## ContactTypes

contactTypeId	name
1	EMAIL
2	PHONE
3	WHATSAPP

---

## Contacts

contactId	contactTypeId	value
1	1	juan@mail.com
2	2	88880001
3	3	88880001
4	1	ana@mail.com
5	2	88880002

---

## UserContacts

userContactId	userId	contactId	isPrimary
1	1	1	true
2	1	2	false
3	1	3	false
4	2	4	true
5	2	5	false

---

## Provinces

provinceId	name
1	San José
2	Alajuela

---

## Cantons

cantonId	provinceId	name
1	1	San José
2	2	San Carlos

---

## Districts

districtId	cantonId	name
1	1	Carmen
2	2	Quesada

---

## Addresses

addressId	districtId	exactDetail	latitude	longitude
1	1	100m norte del parque central	9.9281	-84.0907
2	2	Frente al hospital	10.3230	-84.4270

---

## UserAddresses

userAddressId	userId	addressId	typeOfAddressId
1	1	1	1
2	2	2	2