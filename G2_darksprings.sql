DROP PACKAGE employee_package;

DROP VIEW customer_view;
DROP VIEW employee_view;

DROP PROCEDURE insert_customer;
DROP PROCEDURE delivery_schedule;
DROP PROCEDURE create_order;

DROP TRIGGER update_bill_billamount;
DROP TRIGGER return_order;

DROP ROLE ACCOUNTANT;
DROP ROLE DELIVERYMANAGER;

DROP INDEX customer_idx;
DROP INDEX employee_idx;

BEGIN
DBMS_SCHEDULER.DROP_JOB('update_inventory');
END;
/

-- DDL STATEMENTS
ALTER TABLE contract DROP CONSTRAINT contract_billingzip_CK;
ALTER TABLE contract DROP CONSTRAINT contract_frequency_CK;

ALTER TABLE customer DROP CONSTRAINT customer_zip_CK;
ALTER TABLE customer DROP CONSTRAINT customer_phone_CK;
ALTER TABLE customer DROP CONSTRAINT customer_email_CK;
ALTER TABLE customer DROP CONSTRAINT customer_customertype_CK;
ALTER TABLE customer DROP CONSTRAINT customer_islead_CK;

ALTER TABLE orderdetails DROP CONSTRAINT orderdetails_quantity_ck;

ALTER TABLE orders DROP CONSTRAINT orders_deposit_ck;

ALTER TABLE employee DROP CONSTRAINT employee_phone_CK;
ALTER TABLE employee DROP CONSTRAINT employee_fax_CK;
ALTER TABLE employee DROP CONSTRAINT employee_email_CK;
ALTER TABLE employee DROP CONSTRAINT employee_zip_CK;
ALTER TABLE employee DROP CONSTRAINT employee_gender_CK;
ALTER TABLE employee DROP CONSTRAINT employee_evaluationscore_CK;

ALTER TABLE item DROP CONSTRAINT item_price_CK;
ALTER TABLE item DROP CONSTRAINT item_quantityonhand_CK;

ALTER TABLE bill DROP CONSTRAINT bill_employee_fk;
ALTER TABLE bill DROP CONSTRAINT bill_orders_fk;

ALTER TABLE contract DROP CONSTRAINT contract_customer_fk;
ALTER TABLE contract DROP CONSTRAINT contract_employee_fk;

ALTER TABLE customer DROP CONSTRAINT customer_contract_fk;
ALTER TABLE customer DROP CONSTRAINT customer_driver_fk; 

ALTER TABLE deliveryschedule DROP CONSTRAINT deliveryschedule_route_fk;

ALTER TABLE driver DROP CONSTRAINT driver_employee_fk;

ALTER TABLE location DROP CONSTRAINT location_customer_fk;

ALTER TABLE location DROP CONSTRAINT location_route_fk;

ALTER TABLE orders DROP CONSTRAINT orders_customer_fk;
ALTER TABLE orders DROP CONSTRAINT orders_customer_fkv2;
ALTER TABLE orders DROP CONSTRAINT orders_deliveryschedule_fk; 

ALTER TABLE orderdetails DROP CONSTRAINT orderdetails_item_fk;
ALTER TABLE orderdetails DROP CONSTRAINT orderdetails_orders_fk;

ALTER TABLE route DROP CONSTRAINT route_driver_fk;
ALTER TABLE route DROP CONSTRAINT route_employee_fk;

ALTER TABLE bill DROP CONSTRAINT bill_pk;
ALTER TABLE contract DROP CONSTRAINT contract_pk;
ALTER TABLE customer DROP CONSTRAINT customer_pk;
ALTER TABLE deliveryschedule DROP CONSTRAINT deliveryschedule_pk;
ALTER TABLE driver DROP CONSTRAINT driver_pk;
ALTER TABLE employee DROP CONSTRAINT employee_pk;
ALTER TABLE item DROP CONSTRAINT item_pk;
ALTER TABLE location DROP CONSTRAINT location_pk;
ALTER TABLE orders DROP CONSTRAINT orders_pk;
ALTER TABLE orderdetails DROP CONSTRAINT orderdetails_pk;
ALTER TABLE route DROP CONSTRAINT route_pk;

DROP TABLE bill;
DROP TABLE contract;
DROP TABLE orders;
DROP TABLE orderdetails;
DROP TABLE deliveryschedule;
DROP TABLE employee;
DROP TABLE driver;
DROP TABLE location;
DROP TABLE route;
DROP TABLE item;
DROP TABLE customer;

DROP SEQUENCE customer_customerID_seq;
DROP SEQUENCE employee_employeeID_seq;
DROP SEQUENCE bill_billID_seq;
DROP SEQUENCE orders_ordersID_seq;


CREATE TABLE bill (
    billid        NUMBER(7) NOT NULL,
    orderid       NUMBER(7) NOT NULL,
    employeeid    NUMBER(7) NOT NULL,
    datecreated   DATE DEFAULT SYSDATE NOT NULL,
    datedue       DATE NOT NULL,
    datepaid      DATE,
    totalbill     NUMBER(10) NOT NULL,
    latefee       NUMBER(7, 2) DEFAULT 0
);

ALTER TABLE bill ADD CONSTRAINT bill_pk PRIMARY KEY ( billid );

CREATE TABLE contract (
    contractid         NUMBER(7) NOT NULL,
    signeddate         DATE NOT NULL,
    servicestartdate   DATE NOT NULL,
    serviceenddate     DATE NOT NULL,
    customerid         NUMBER(7) NOT NULL,
    employeeid         NUMBER(7) NOT NULL,
    billingstreet      VARCHAR2(40) NOT NULL,
    billingcity        VARCHAR2(20) NOT NULL,
    billingzip         VARCHAR2(5) NOT NULL,
    billlingstate      VARCHAR2(2) NOT NULL,
    deposit            NUMBER(7, 2),
    methodofpayment    VARCHAR2(50) NOT NULL,
    lastupdated        DATE NOT NULL,
    frequency          VARCHAR2(20) NOT NULL
);

ALTER TABLE contract ADD CONSTRAINT contract_billingzip_CK CHECK ( REGEXP_LIKE ( billingzip,
                                               '[0-9]{5}' ) );

ALTER TABLE contract ADD CONSTRAINT contract_frequency_CK CHECK ( frequency IN (
	'daily',
	'monthly',
	'on-demand',
	'weekly'
) );

ALTER TABLE contract ADD CONSTRAINT contract_pk PRIMARY KEY ( contractid );

CREATE TABLE customer (
    customerid          NUMBER(7) NOT NULL,
    customername        VARCHAR2(40) NOT NULL,
    contactfname        VARCHAR2(40) NOT NULL,
    contactlname        VARCHAR2(40) NOT NULL,
    street              VARCHAR2(40) NOT NULL,
    city                VARCHAR2(20) NOT NULL,
    zip                 VARCHAR2(5) NOT NULL,
    state               VARCHAR2(2) NOT NULL,
    phone               VARCHAR2(10) NOT NULL,
    email               VARCHAR2(40) NOT NULL,
    islead              CHAR(1),
    numberofemployees   NUMBER(5),
    registereddate      DATE DEFAULT SYSDATE NOT NULL ,
    "comment"           VARCHAR2(300),
    employeeid          NUMBER(7),
    customertype        VARCHAR2(50) NOT NULL,
    referredby          NUMBER(7),
    datereferred        DATE
);

CREATE INDEX customer_idx ON customer(customername);

ALTER TABLE customer ADD CONSTRAINT customer_zip_CK CHECK ( REGEXP_LIKE ( zip,
                                               '[0-9]{5}' ) );

ALTER TABLE customer ADD CONSTRAINT customer_phone_CK CHECK ( REGEXP_LIKE ( phone,
                                               '[0-9]{10}' ) );

ALTER TABLE customer ADD CONSTRAINT customer_email_CK CHECK ( REGEXP_LIKE ( email,
                                               '@' ) );

ALTER TABLE customer ADD CONSTRAINT customer_customertype_CK CHECK ( customertype IN (
	'Department in new company',
	'Department in same company',
	'Large corporation',
	'Service organization',
	'Small business'
) );

ALTER TABLE customer ADD CONSTRAINT customer_islead_CK CHECK ( islead IN (
	'Y',
	'N'
) );

ALTER TABLE customer ADD CONSTRAINT customer_pk PRIMARY KEY ( customerid );

CREATE TABLE deliveryschedule (
    deliveryid         NUMBER(7) NOT NULL,
    servicedate        DATE NOT NULL,
    routeid            NUMBER(7) NOT NULL,
    timearrived        DATE,
    timedeparted       DATE,
    customercomments   VARCHAR2(300),
    drivercomments     VARCHAR2(300)
);

ALTER TABLE deliveryschedule ADD CONSTRAINT deliveryschedule_pk PRIMARY KEY ( deliveryid );

CREATE TABLE driver (
    employeeid   NUMBER(7) NOT NULL,
    licenseno    VARCHAR2(13) NOT NULL
);

ALTER TABLE driver ADD CONSTRAINT driver_pk PRIMARY KEY ( employeeid );

CREATE TABLE employee (
    employeeid        NUMBER(7) NOT NULL,
    fname             VARCHAR2(40) NOT NULL,
    lname             VARCHAR2(40) NOT NULL,
    phone             VARCHAR2(10) NOT NULL,
    fax               VARCHAR2(10),
    street            VARCHAR2(40) NOT NULL,
    city              VARCHAR2(20) NOT NULL,
    zip               VARCHAR2(5) NOT NULL,
    state             VARCHAR2(2) NOT NULL,
    hiredate          DATE DEFAULT SYSDATE NOT NULL,
    enddate           DATE,
    dob               DATE,
    role              VARCHAR2(20) NOT NULL,
    gender            VARCHAR2(1) NOT NULL,
    email             VARCHAR2(40) NOT NULL,
    evaluationscore   NUMBER(2)
);

CREATE INDEX employee_idx ON employee(lname);

ALTER TABLE employee ADD CONSTRAINT employee_phone_CK CHECK ( REGEXP_LIKE ( phone,
                                               '[0-9]{10}' ) );

ALTER TABLE employee ADD CONSTRAINT employee_fax_CK CHECK ( REGEXP_LIKE ( fax,
                                               '[0-9]{10}' ) );

ALTER TABLE employee ADD CONSTRAINT employee_zip_CK CHECK ( REGEXP_LIKE ( zip,
                                               '[0-9]{5}' ) );

ALTER TABLE employee ADD CONSTRAINT employee_gender_CK CHECK ( gender IN (
	'F',
	'M'
) );

ALTER TABLE employee ADD CONSTRAINT employee_email_CK CHECK ( REGEXP_LIKE ( email,
                                               '@' ) );
											  
ALTER TABLE employee ADD CONSTRAINT employee_evaluationscore_CK CHECK ( evaluationscore BETWEEN 0 AND 10 );

ALTER TABLE employee ADD CONSTRAINT employee_pk PRIMARY KEY ( employeeid );

CREATE TABLE item (
    itemid           NUMBER(7) NOT NULL,
    itemname         VARCHAR2(40),
    price            NUMBER(7, 2) NOT NULL,
    quantityonhand   INTEGER NOT NULL
);

ALTER TABLE item ADD CONSTRAINT item_price_CK CHECK ( price >= 0 );

ALTER TABLE item ADD CONSTRAINT item_quantityonhand_CK CHECK ( quantityonhand >= 0 );

ALTER TABLE item ADD CONSTRAINT item_pk PRIMARY KEY ( itemid );

CREATE TABLE location (
    locationid     NUMBER(7) NOT NULL,
    customerid     NUMBER(7) NOT NULL,
    locationname   VARCHAR2(40) NOT NULL,
    routeid        NUMBER(7) NOT NULL
);

ALTER TABLE location ADD CONSTRAINT location_pk PRIMARY KEY ( locationid );

CREATE TABLE orders (
    orderid       NUMBER(7) NOT NULL,
    dateordered   DATE NOT NULL,
    placedby      NUMBER(7) NOT NULL,
    datereturned  DATE,
    returnedby    NUMBER(7),
    description   VARCHAR2(50),
    deposit       NUMBER(10),
    deliveryid    NUMBER(7)
);

ALTER TABLE orders ADD CONSTRAINT orders_deposit_ck CHECK ( deposit >= 0 );

ALTER TABLE orders ADD CONSTRAINT orders_pk PRIMARY KEY ( orderid );

CREATE TABLE orderdetails (
    orderid    NUMBER(7) NOT NULL,
    itemid     NUMBER(7) NOT NULL,
    quantity   NUMBER(5)
);

ALTER TABLE orderdetails ADD CONSTRAINT orderdetails_quantity_ck CHECK ( quantity > 0 );

ALTER TABLE orderdetails ADD CONSTRAINT orderdetails_pk PRIMARY KEY ( orderid,
                                                                      itemid );

CREATE TABLE route (
    routeid     NUMBER(7) NOT NULL,
    routename   VARCHAR2(20) NOT NULL,
    driverid    NUMBER(7) NOT NULL,
    managerid   NUMBER(7) NOT NULL
);

ALTER TABLE route ADD CONSTRAINT route_pk PRIMARY KEY ( routeid );

ALTER TABLE bill
    ADD CONSTRAINT bill_employee_fk FOREIGN KEY ( employeeid )
        REFERENCES employee ( employeeid );

ALTER TABLE bill
    ADD CONSTRAINT bill_orders_fk FOREIGN KEY ( orderid )
        REFERENCES orders ( orderid );

ALTER TABLE contract
    ADD CONSTRAINT contract_customer_fk FOREIGN KEY ( customerid )
        REFERENCES customer ( customerid );

ALTER TABLE contract
    ADD CONSTRAINT contract_employee_fk FOREIGN KEY ( employeeid )
        REFERENCES employee ( employeeid );

ALTER TABLE customer
    ADD CONSTRAINT customer_contract_fk FOREIGN KEY ( referredby )
        REFERENCES customer ( customerid );

ALTER TABLE customer
    ADD CONSTRAINT customer_driver_fk FOREIGN KEY ( employeeid )
        REFERENCES driver ( employeeid );

ALTER TABLE deliveryschedule
    ADD CONSTRAINT deliveryschedule_route_fk FOREIGN KEY ( routeid )
        REFERENCES route ( routeid );

ALTER TABLE driver
    ADD CONSTRAINT driver_employee_fk FOREIGN KEY ( employeeid )
        REFERENCES employee ( employeeid );

ALTER TABLE location
    ADD CONSTRAINT location_customer_fk FOREIGN KEY ( customerid )
        REFERENCES customer ( customerid );

ALTER TABLE location
    ADD CONSTRAINT location_route_fk FOREIGN KEY ( routeid )
        REFERENCES route ( routeid );

ALTER TABLE orders
    ADD CONSTRAINT orders_customer_fk FOREIGN KEY ( returnedby )
        REFERENCES customer ( customerid );

ALTER TABLE orders
    ADD CONSTRAINT orders_customer_fkv2 FOREIGN KEY ( placedby )
        REFERENCES customer ( customerid );

ALTER TABLE orders
    ADD CONSTRAINT orders_deliveryschedule_fk FOREIGN KEY ( deliveryid )
        REFERENCES deliveryschedule ( deliveryid );

ALTER TABLE orderdetails
    ADD CONSTRAINT orderdetails_item_fk FOREIGN KEY ( itemid )
        REFERENCES item ( itemid );

ALTER TABLE orderdetails
    ADD CONSTRAINT orderdetails_orders_fk FOREIGN KEY ( orderid )
        REFERENCES orders ( orderid );

ALTER TABLE route
    ADD CONSTRAINT route_driver_fk FOREIGN KEY ( driverid )
        REFERENCES driver ( employeeid );

ALTER TABLE route
    ADD CONSTRAINT route_employee_fk FOREIGN KEY ( managerid )
        REFERENCES employee ( employeeid );


		
-- SEQUENCES				
CREATE SEQUENCE customer_customerID_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE employee_employeeID_seq
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE bill_billID_seq 
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

CREATE SEQUENCE orders_ordersID_seq 
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;


-- INSERTS
--EMPLOYEE
INSERT INTO Employee VALUES(EMPLOYEE_EMPLOYEEID_SEQ.nextval,'Ben','Roethlisberger','4121234567','4121234510','4000 Forbes','Pittsuburgh','15206','PA','20-Feb-95',NULL,'20-Feb-70','Delivery Manager','M','BenRoethlisberger@gmail.com',0);
INSERT INTO Employee VALUES(EMPLOYEE_EMPLOYEEID_SEQ.nextval,'Jane','Campbell','4121234568','4121234511','9999 Winfield','New York','14830','NY','02-Mar-00',NULL,'02-Mar-80','Driver','F','JamesConner@gmail.com',2);
INSERT INTO Employee VALUES(EMPLOYEE_EMPLOYEEID_SEQ.nextval,'Casey','Murphy','4121234569','4121234512','2077 Hayes','San Francisco','94117','CA','02-May-10',NULL,'02-May-90','Account Rep','F','JuJuSmith-Schuster@gmail.com',3);
INSERT INTO Employee VALUES(EMPLOYEE_EMPLOYEEID_SEQ.nextval,'Antonio','Brown','4121234570','4121234513','1800 Lightcap','Philadelphia','12345','PA','02-Feb-99',NULL,'02-Feb-70','Exective','M','AntonioBrown@gmail.com',4);
INSERT INTO Employee VALUES(EMPLOYEE_EMPLOYEEID_SEQ.nextval,'Vance','McDonald','4121234571','4121234514','1300 Lightcap','Philadelphia','12345','PA','12-May-15',NULL,'12-May-90','Driver','M','VanceMcDonald@gmail.com',5);
INSERT INTO Employee VALUES(EMPLOYEE_EMPLOYEEID_SEQ.nextval,'Mason','Rudolph','4121234572','4121234515','4000 Forbes','Pittsuburgh','15206','PA','12-Dec-15',NULL,'12-May-90','Salesperson','M','MasonRudolph@gmail.com',10);
INSERT INTO Employee VALUES(EMPLOYEE_EMPLOYEEID_SEQ.nextval,'Roosevelt','Nix','4121234573','4121234516','9999 Winfield','New York','14830','NY','12-Sep-15','12-Sep-18','12-May-90','Salesperson','M','RooseveltNix@gmail.com',1);
INSERT INTO Employee VALUES(EMPLOYEE_EMPLOYEEID_SEQ.nextval,'Ryan','Switzer','4121234574','4121234517','2077 Hayes','San Francisco','94117','CA','12-Sep-00',NULL,'02-Mar-80','Driver','F','RyanSwitzer@gmail.com',9);
COMMIT;

--DRIVER
INSERT INTO Driver VALUES(2,'012345678');
INSERT INTO Driver VALUES(5,'BRAUNWH559RCS');
INSERT INTO Driver VALUES(8,'987654321');
COMMIT;

--CUSTOMER
INSERT INTO Customer VALUES(CUSTOMER_CUSTOMERID_SEQ.nextval,'Heinz College','Sidney','Crosby','3640 Colonel Glenn','Fairborn','45324','OH','1000009987','SidneyCrosby@gmail.com','N',100,'01-Sep-16',NULL,NULL,'Service organization',NULL,NULL);
INSERT INTO Customer VALUES(CUSTOMER_CUSTOMERID_SEQ.nextval,'Tepper College','Evgeni','Malkin','1000 XYZ','Warwick','12345','RI','4010123456','EvgeniMalkin@gmail.com','N',99999,'20-Oct-18',NULL,2,'Large corporation',1,'20-Oct-18');
INSERT INTO Customer VALUES(CUSTOMER_CUSTOMERID_SEQ.nextval,'Sloan College','Kris','Letang','1000 Forbes','New York','14830','NY','6070123457','KrisLetang@gmail.com','N',20,'28-Oct-18',NULL,5,'Small business',2,'28-Oct-18');
INSERT INTO Customer VALUES(CUSTOMER_CUSTOMERID_SEQ.nextval,'Pittsburgh University','Phil','Kessel','2000 Living Place','New York','14831','NY','6070123458','PhilKessel@gmail.com','N',10,'01-Jan-19',NULL,8,'Department in same company',2,'01-Jan-19');
INSERT INTO Customer VALUES(CUSTOMER_CUSTOMERID_SEQ.nextval,'Google','Patric','Hornqvist','3000Sorcial','New York','14832','NY','6070123459','PatricHornqvist@gmail.com','Y',3,'20-Feb-19','aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',2,'Department in new company',1,NULL);
COMMIT;

--CONTRACT
INSERT INTO Contract VALUES(1,'01-Sep-18','21-Sep-18','01-Sep-19',1,6,'3000Sorcial','New York','14833','NY',0,'Card','01-Sep-18','monthly');
INSERT INTO Contract VALUES(2,'20-Oct-18','20-Dec-18','20-Dec-19',2,6,'1000 Living Place','Pittsburgh','15206','PA',100,'Cash','20-Oct-18','weekly');
INSERT INTO Contract VALUES(3,'28-Oct-18','28-Jan-19','28-Jan-20',3,6,'2000 Morewood','Pittsburgh','15000','PA',100,'Card','28-Oct-18','daily');
INSERT INTO Contract VALUES(4,'01-Jan-19','01-Jan-19','01-Jan-20',4,6,'3000 Morewood','Pittsburgh','15000','PA',100,'Card','20-Feb-19','on-demand');
COMMIT;

--ITEM
INSERT INTO Item VALUES(1,'cooler',500,5000);
INSERT INTO Item VALUES(2,'large bottle of water',10,10000);
INSERT INTO Item VALUES(3,'small bottle of water',5,10000);
INSERT INTO Item VALUES(4,'cup',3,6000);
INSERT INTO Item VALUES(5,'holder',2,4000);
COMMIT;

--ROUTE
INSERT INTO Route VALUES(1,'Route A',2,1);
INSERT INTO Route VALUES(2,'Route B',5,1);
INSERT INTO Route VALUES(3,'Route C',8,1);
COMMIT;

--DELIVERYSCHEDULE
INSERT INTO DeliverySchedule VALUES(1,'04-Oct-18',1,TO_DATE('04-Oct-18 10:00 AM','dd-mon-yy hh:mi PM'),TO_DATE('04-Oct-18 10:05 AM','dd-mon-yy hh:mi AM'),'Good service!','Polite');
INSERT INTO DeliverySchedule VALUES(2,'04-Nov-18',1,TO_DATE('04-Nov-18 10:00 AM','dd-mon-yy hh:mi PM'),TO_DATE('04-Nov-18 10:05 AM','dd-mon-yy hh:mi AM'),'Efficient','Good');
INSERT INTO DeliverySchedule VALUES(3,'31-Dec-18',1,TO_DATE('09-Dec-31 08:32 PM','dd-mon-yy hh:mi PM'),TO_DATE('09-Dec-31 08:40 PM','dd-mon-yy hh:mi PM'),'Bad!','Bad attitude');
INSERT INTO DeliverySchedule VALUES(4,'31-Dec-18',2,TO_DATE('09-Dec-31 09:32 PM','dd-mon-yy hh:mi PM'),TO_DATE('09-Dec-31 09:40 PM','dd-mon-yy hh:mi PM'),'Bad!','Bad attitude');
INSERT INTO DeliverySchedule VALUES(5,'09-Jan-19',1,TO_DATE('09-Jan-19 08:32 AM','dd-mon-yy hh:mi PM'),TO_DATE('09-Jan-19 08:53 AM','dd-mon-yy hh:mi AM'),'Efficient','Good');
INSERT INTO DeliverySchedule VALUES(6,'09-Jan-19',2,TO_DATE('09-Jan-19 11:32 AM','dd-mon-yy hh:mi PM'),TO_DATE('09-Jan-19 01:33 PM','dd-mon-yy hh:mi PM'),'Efficient','Good');
INSERT INTO DeliverySchedule VALUES(7,'29-Jan-19',3,TO_DATE('29-Jan-19 08:32 AM','dd-mon-yy hh:mi PM'),TO_DATE('29-Jan-19 08:39 AM','dd-mon-yy hh:mi AM'),'Good service!','Polite');
INSERT INTO DeliverySchedule VALUES(8,'30-Jan-19',3,TO_DATE('30-Jan-19 11:32 AM','dd-mon-yy hh:mi PM'),TO_DATE('30-Jan-19 11:42 AM','dd-mon-yy hh:mi AM'),'Efficient','Good');
INSERT INTO DeliverySchedule VALUES(9,'31-Jan-19',3,TO_DATE('31-Jan-19 11:32 AM','dd-mon-yy hh:mi PM'),TO_DATE('31-Jan-19 11:52 AM','dd-mon-yy hh:mi AM'),'Efficient','Good');
INSERT INTO DeliverySchedule VALUES(10,'04-Feb-19',1,TO_DATE('04-Feb-19 10:00 AM','dd-mon-yy hh:mi PM'),TO_DATE('04-Feb-19 10:05 AM','dd-mon-yy hh:mi AM'),'Good service!','Polite');
INSERT INTO DeliverySchedule VALUES(11,'05-Feb-19',3,TO_DATE('05-Feb-19 10:00 AM','dd-mon-yy hh:mi PM'),TO_DATE('05-Feb-19 10:00 AM','dd-mon-yy hh:mi AM'),'Good service!','Polite');
INSERT INTO DeliverySchedule VALUES(12,'05-Feb-19',3,TO_DATE('05-Feb-19 11:00 AM','dd-mon-yy hh:mi PM'),TO_DATE('05-Feb-19 11:59 AM','dd-mon-yy hh:mi AM'),'Good service!','Polite');
INSERT INTO DeliverySchedule VALUES(13,'06-Feb-19',3,TO_DATE('06-Feb-19 11:00 AM','dd-mon-yy hh:mi PM'),TO_DATE('06-Feb-19 11:50 AM','dd-mon-yy hh:mi AM'),'Good service!','Polite');
INSERT INTO DeliverySchedule VALUES(14,'07-Feb-19',3,TO_DATE('07-Feb-19 10:00 AM','dd-mon-yy hh:mi PM'),TO_DATE('07-Feb-19 10:00 AM','dd-mon-yy hh:mi AM'),'Efficient','Good');
INSERT INTO DeliverySchedule VALUES(15,'07-Feb-19',3,TO_DATE('07-Feb-19 11:00 AM','dd-mon-yy hh:mi PM'),TO_DATE('07-Feb-19 11:59 AM','dd-mon-yy hh:mi AM'),'Bad!','Bad attitude');
COMMIT;

--LOCATION
INSERT INTO Location VALUES(1,1,'Hamburgh Hall',1);
INSERT INTO Location VALUES(2,2,'Hamburgh Hall',2);
INSERT INTO Location VALUES(3,3,'Tepper',3);
INSERT INTO Location VALUES(4,4,'UC',3);
INSERT INTO Location VALUES(5,5,'Hunt',1);
COMMIT;

--ORDER
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'03-Oct-18',1,NULL,NULL,'I need a printed receipt!',0,1);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'31-Oct-18',1,NULL,NULL,'Be quick',0,2);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'30-Dec-18',1,NULL,NULL,NULL,0,3);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'30-Dec-18',2,NULL,NULL,'No',0,4);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'08-Jan-19',1,NULL,NULL,NULL,0,5);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'08-Jan-19',2,NULL,NULL,NULL,100,6);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'28-Jan-19',3,NULL,NULL,'Be quick',50,7);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'29-Jan-19',3,NULL,NULL,NULL,50,8);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'30-Jan-19',3,NULL,NULL,'Receipt!',50,9);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'03-Feb-19',3,NULL,NULL,NULL,50,10);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'03-Feb-19',3,NULL,NULL,NULL,50,10);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'03-Feb-19',3,NULL,NULL,NULL,50,10);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'04-Feb-19',1,'04-Feb-19',1,NULL,0,11);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'04-Feb-19',3,NULL,NULL,NULL,50,12);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'05-Feb-19',3,NULL,NULL,NULL,50,13);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'06-Feb-19',3,NULL,NULL,NULL,50,14);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'06-Feb-19',3,NULL,NULL,NULL,50,14);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'06-Feb-19',3,NULL,NULL,NULL,50,14);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'06-Feb-19',3,NULL,NULL,NULL,50,14);
INSERT INTO Orders VALUES(orders_ordersID_seq.nextval,'06-Feb-19',4,NULL,NULL,NULL,300,15);
COMMIT;

--ORDERDETAILS
INSERT INTO OrderDetails VALUES(1,1,300);
INSERT INTO OrderDetails VALUES(1,2,1);
INSERT INTO OrderDetails VALUES(1,3,1);
INSERT INTO OrderDetails VALUES(2,1,300);
INSERT INTO OrderDetails VALUES(2,2,1);
INSERT INTO OrderDetails VALUES(2,3,1);
INSERT INTO OrderDetails VALUES(3,1,300);
INSERT INTO OrderDetails VALUES(3,2,1);
INSERT INTO OrderDetails VALUES(3,3,1);
INSERT INTO OrderDetails VALUES(4,3,500);
INSERT INTO OrderDetails VALUES(4,2,300);
INSERT INTO OrderDetails VALUES(5,1,300);
INSERT INTO OrderDetails VALUES(5,2,1);
INSERT INTO OrderDetails VALUES(5,3,1);
INSERT INTO OrderDetails VALUES(6,2,100);
INSERT INTO OrderDetails VALUES(7,2,100);
INSERT INTO OrderDetails VALUES(8,2,100);
INSERT INTO OrderDetails VALUES(9,2,100);
INSERT INTO OrderDetails VALUES(10,2,100);
INSERT INTO OrderDetails VALUES(11,2,100);
INSERT INTO OrderDetails VALUES(12,2,100);
INSERT INTO OrderDetails VALUES(13,1,100);
INSERT INTO OrderDetails VALUES(13,2,300);
INSERT INTO OrderDetails VALUES(13,3,1);
INSERT INTO OrderDetails VALUES(14,2,100);
INSERT INTO OrderDetails VALUES(15,3,5000);
INSERT INTO OrderDetails VALUES(20,1,50);
INSERT INTO OrderDetails VALUES(20,2,100);
INSERT INTO OrderDetails VALUES(20,3,20);
COMMIT;

--BILL
INSERT INTO Bill VALUES(bill_billID_seq.nextval,1,3,'03-Oct-18','10-Oct-18','10-Oct-18',150015,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,2,3,'31-Oct-18','07-Oct-18','07-Oct-18',150015,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,3,3,'30-Dec-18','06-Jan-19','06-Jan-19',150015,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,4,3,'30-Dec-18','06-Jan-19','07-Jan-19',6050,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,5,3,'08-Jan-19','15-Jan-19','17-Jan-19',150015,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,6,3,'08-Jan-19','15-Jan-19',NULL,11000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,7,3,'28-Jan-19','04-Feb-19','28-Jan-19',1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,8,3,'29-Jan-19','05-Feb-19','29-Jan-19',1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,9,3,'30-Jan-19','06-Feb-19','30-Jan-19',1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,10,3,'03-Feb-19','10-Feb-19','03-Feb-19',1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,11,3,'03-Feb-19','10-Feb-19','03-Feb-19',1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,12,3,'03-Feb-19','10-Feb-19','03-Feb-19',1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,13,3,'04-Feb-19','11-Feb-19','04-Feb-19',-1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,14,3,'04-Feb-19','11-Feb-19','04-Feb-19',1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,15,3,'05-Feb-19','12-Feb-19','05-Feb-19',1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,16,3,'06-Feb-19','13-Feb-19','13-Feb-19',1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,17,3,'06-Feb-19','13-Feb-19','13-Feb-19',1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,18,3,'06-Feb-19','13-Feb-19','11-Feb-19',1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,19,3,'06-Feb-19','13-Feb-19','13-Feb-19',1000,0);
INSERT INTO Bill VALUES(bill_billID_seq.nextval,20,3,'26-Feb-19','31-Mar-19',NULL,25000,0);
COMMIT;


-- PACKAGE
CREATE OR REPLACE PACKAGE employee_package
AS
	PROCEDURE hire_employee(
		   p_fname IN employee.fname%TYPE,
		   p_lname IN employee.lname%TYPE,
		   p_phone IN employee.phone%TYPE,
		   p_fax IN employee.fax%TYPE,
		   p_street IN employee.street%TYPE,
		   p_city IN employee.city%TYPE,
		   p_zip IN employee.zip%TYPE,
		   p_state IN employee.state%TYPE,
		   p_dob IN employee.dob%TYPE,
		   p_role IN employee.role%TYPE,
		   p_gender IN employee.gender%TYPE,
		   p_email IN employee.email%TYPE);
		   
	PROCEDURE fire_employee(p_employeeid IN employee.employeeid%TYPE);
	
END employee_package;
/

CREATE OR REPLACE PACKAGE BODY employee_package
AS
	PROCEDURE hire_employee(
		   p_fname IN employee.fname%TYPE,
		   p_lname IN employee.lname%TYPE,
		   p_phone IN employee.phone%TYPE,
		   p_fax IN employee.fax%TYPE,
		   p_street IN employee.street%TYPE,
		   p_city IN employee.city%TYPE,
		   p_zip IN employee.zip%TYPE,
		   p_state IN employee.state%TYPE,
		   p_dob IN employee.dob%TYPE,
		   p_role IN employee.role%TYPE,
		   p_gender IN employee.gender%TYPE,
		   p_email IN employee.email%TYPE)
	AS
	BEGIN
		INSERT INTO employee VALUES(employee_employeeid_seq.nextval, p_fname, p_lname, 
									p_phone, p_fax, p_street, p_city, p_zip, p_state, SYSDATE, 
									NULL, p_dob, p_role, p_gender, p_email, 0);
		COMMIT;
	END hire_employee;
	
	PROCEDURE fire_employee(p_employeeid IN employee.employeeid%TYPE)
	AS
	BEGIN
		UPDATE employee
		SET enddate = SYSDATE,
			evaluationscore = NULL
		WHERE employeeid = p_employeeid;
	END fire_employee;
END employee_package;
/

-- VIEWS
-- customer view
CREATE VIEW customer_view AS
SELECT customerID, customerName, street, city, zip, state, registeredDate, customerType
FROM customer;

-- employee view
CREATE VIEW employee_view AS
SELECT employeeID, fName, lName, email, hireDate
FROM employee;


-- PROCEDURES
-- create job to update inventory


SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE my_job_procedure
IS
old_quantity item.quantityonhand%TYPE;
new_quantity item.quantityonhand%TYPE ;
CURSOR c1 IS SELECT quantityonhand FROM item WHERE quantityonhand < 6000 FOR UPDATE of quantityonhand;
BEGIN
    OPEN c1;
    LOOP
    FETCH c1 INTO old_quantity;
    new_quantity := old_quantity + 5000;
    EXIT WHEN c1%NOTFOUND;
    UPDATE item SET quantityonhand = new_quantity WHERE CURRENT OF c1;
    END LOOP;
    CLOSE c1;
COMMIT;
END;
/

BEGIN
DBMS_SCHEDULER.CREATE_JOB(
job_name => 'update_inventory',
job_type => 'STORED_PROCEDURE',
job_action => 'my_job_procedure',
start_date => SYSDATE,
repeat_interval => 'FREQ = minutely; INTERVAL = 5');
END;
/



-- get the delivery schedule of driver for a paritcular date
CREATE OR REPLACE PROCEDURE delivery_schedule(f_name IN employee.fname%TYPE, 
                                              l_name IN employee.lname%TYPE,
                                              service_Date IN DeliverySchedule.serviceDate%TYPE)
AS
TYPE new_table IS RECORD(
    fname employee.fname%TYPE, 
    lname employee.lname%TYPE,
    serviceDate DeliverySchedule.serviceDate%TYPE,
    routeName route.routeName%TYPE,
    customerName customer.customerName%TYPE,
    orderid orders.orderid%TYPE,
    itemname item.itemname%TYPE,
    quantity orderdetails.quantity%TYPE);
new_table1 new_table;
excep_1 EXCEPTION;
fname2 employee.fname%TYPE;

CURSOR c1 (fname1 IN employee.fname%TYPE, lname1 IN employee.lname%TYPE, serviceDate1 IN DeliverySchedule.serviceDate%TYPE) is
    SELECT e.fname, e.lname, d.serviceDate, r.routeName, c.customerName, o.orderid, i.itemname, od.quantity
    FROM employee e
    FULL OUTER JOIN route r ON e.employeeid = r.driverid
    FULL OUTER JOIN customer c ON e.employeeid = c.employeeid
    FULL OUTER JOIN DeliverySchedule d ON r.routeid = d.routeid
    FULL OUTER JOIN orders o ON o.deliveryid = d.deliveryid
    FULL OUTER JOIN orderdetails od ON o.orderid = od.orderid
    FULL OUTER JOIN item i ON od.itemid = i.itemid
    WHERE UPPER(e.fname) LIKE '%'|| UPPER(fname1)||'%' AND UPPER(e.lname) LIKE '%'||UPPER(lname1)||'%' AND d.serviceDate LIKE '%'||serviceDate1||'%';
BEGIN 
    SELECT count(*) into fname2 from employee 
    FULL OUTER JOIN route ON employee.employeeid = route.driverid 
    FULL OUTER JOIN DeliverySchedule ON route.routeid = DeliverySchedule.routeid
    WHERE f_name in employee.fname AND l_name in employee.lname AND service_Date in DeliverySchedule.serviceDate;
    If fname2 = 0 THEN 
    RAISE excep_1;
    ELSE
    OPEN c1(f_name, l_name, service_Date);
    DBMS_OUTPUT.PUT(' '||'Driver Name: '||f_name||' '||l_name);
    DBMS_OUTPUT.NEW_LINE;
    DBMS_OUTPUT.PUT(' '||'Service Date: '||service_Date);
    DBMS_OUTPUT.NEW_LINE;
    LOOP
        FETCH c1 INTO new_table1;
        EXIT WHEN c1%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(
        ' Route Name: '||new_table1.routeName ||';'||
        ' Customer Name: '||new_table1.customerName ||';'||
        ' Order ID: '||new_table1.orderid ||';'||
        ' Item Name: '||new_table1.itemname ||';'||
        ' Item Quantity:'||new_table1.quantity||';');
    END LOOP;
    CLOSE c1;
    END IF;
COMMIT;
EXCEPTION 
    WHEN excep_1 THEN
    DBMS_OUTPUT.PUT_LINE ('Please check the inputs you entered');
    WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE ('Employee information does not exist'); 
    WHEN ZERO_DIVIDE THEN
    DBMS_OUTPUT.PUT_LINE ('The number cannot be divided by zero'); 
    WHEN TOO_MANY_ROWS THEN
    DBMS_OUTPUT.PUT_LINE ('The input returns too many row'); 
    WHEN INVALID_CURSOR THEN 
    DBMS_OUTPUT.PUT_LINE ('The cursor is invalid');
    WHEN CURSOR_ALREADY_OPEN THEN
    DBMS_OUTPUT.PUT_LINE ('The cursor is already open');   
    WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE ('The PLSQL procedure executed by '|| User || ' returned and unhandled exception on ' || SYSDATE);
END;
/


-- insertCustomer procedure
CREATE OR REPLACE PROCEDURE insert_customer(
    v_customername IN customer.customername%TYPE,
    v_contactFName IN customer.contactFName%TYPE,
    v_contactLName IN customer.contactLName%TYPE,
    v_street IN customer.street%TYPE,
    v_city IN customer.city%TYPE,
    v_zip IN customer.zip%TYPE,
    v_state IN customer.state%TYPE,
    v_phone IN customer.phone%TYPE,
    v_email IN customer.email%TYPE,
    v_isLead IN customer.isLead%TYPE,
    v_numberOfEmployees IN customer.numberofemployees%TYPE,
    v_registeredDate IN customer.registeredDate%TYPE,
    v_comment IN customer."comment"%TYPE,
    v_employeeID IN customer.employeeID%TYPE,
    v_customerType IN customer.customerType%TYPE,
    v_referredBy IN customer.referredBy%TYPE,
    v_dateReferred IN customer.dateReferred%TYPE
    )
IS
BEGIN

	INSERT INTO customer (customerID,customername,contactFName,contactLName,street,city,zip,state,phone,email,isLead,numberofemployees,registeredDate,"comment",employeeID,customerType,referredBy,dateReferred )
	VALUES (customer_customerID_seq.nextval, v_customername, v_contactFName, v_contactLName, v_street, v_city, v_zip, v_state, v_phone, v_email, v_isLead, v_numberOfEmployees, v_registeredDate, v_comment, v_employeeID, v_customerType, v_referredBy, v_dateReferred);
	commit;
END;
/

-- create an order
CREATE OR REPLACE PROCEDURE create_order(item1 IN orderdetails.itemid%type,item1_qty IN orderdetails.quantity%type,
										item2 IN orderdetails.itemid%type,item2_qty IN orderdetails.quantity%type,
										item3 IN orderdetails.itemid%type,item3_qty IN orderdetails.quantity%type,
										item4 IN orderdetails.itemid%type,item4_qty IN orderdetails.quantity%type,
										item5 IN orderdetails.itemid%type,item5_qty IN orderdetails.quantity%type,
										cust_id IN orders.placedby%type)
AS
check_flag boolean:=true;
c_itemid item.itemid%type;
c_quantityonhand item.quantityonhand%type;
c_price item.price%type;
cust_data number:=0;
service_enddate contract.serviceenddate%type;
new_order_id orders.orderid%type;
insufficient_quantity EXCEPTION;
no_customer_found EXCEPTION;
CURSOR C_ITEM_QUANTITY IS 
	SELECT ITEMID,QUANTITYONHAND,PRICE FROM ITEM;
BEGIN
	SELECT COUNT(*) INTO CUST_DATA FROM CUSTOMER WHERE CUSTOMERID=cust_id;
	IF cust_data>0 then
		SELECT SERVICEENDDATE INTO service_enddate FROM CONTRACT where customerid=cust_id;
		DBMS_OUTPUT.PUT_LINE('CONTRACT IS VALID');
		IF sql%found AND service_enddate-SYSDATE>=0 THEN
			OPEN C_ITEM_QUANTITY;
			LOOP
			FETCH C_ITEM_QUANTITY INTO c_itemid,c_quantityonhand,c_price;
			EXIT WHEN C_ITEM_QUANTITY%NOTFOUND;
			IF item1=c_itemid and item1_qty>0 and c_quantityonhand-item1_qty<0 then
				check_flag:=false;
			end if;
			IF item2=c_itemid and item2_qty>0 and c_quantityonhand-item2_qty<0 then
				check_flag:=false;
			end if;
			IF item3=c_itemid and item3_qty>0 and c_quantityonhand-item3_qty<0 then
				check_flag:=false;
			end if;
			IF item4=c_itemid and item4_qty>0 and c_quantityonhand-item1_qty<0 then
				check_flag:=false;
			end if;
			IF item5=c_itemid and item5_qty>0 and c_quantityonhand-item5_qty<0 then
				check_flag:=false;
			end if;
			END LOOP;
			CLOSE C_ITEM_QUANTITY;
			IF check_flag=true then
				select orders_ordersid_seq.nextval into new_order_id from dual;
				INSERT INTO ORDERS values(new_order_id,SYSDATE,CUST_ID,NULL,NULL,NULL,NULL,NULL);
				IF item1_qty>0 then
					INSERT INTO orderdetails VALUES(new_order_id,item1,item1_qty);
					UPDATE ITEM SET QUANTITYONHAND=QUANTITYONHAND-ITEM1_QTY WHERE ITEMID=item1;
				END IF;
				IF item2_qty>0 then
					INSERT INTO orderdetails VALUES(new_order_id,item2,item2_qty);
					UPDATE ITEM SET QUANTITYONHAND=QUANTITYONHAND-ITEM2_QTY WHERE ITEMID=item2;
				END IF;
				IF item3_qty>0 then
					INSERT INTO orderdetails VALUES(new_order_id,item3,item3_qty);
					UPDATE ITEM SET QUANTITYONHAND=QUANTITYONHAND-ITEM3_QTY WHERE ITEMID=item3;
				END IF;
				IF item4_qty>0 then
					INSERT INTO orderdetails VALUES(new_order_id,item4,item4_qty);
					UPDATE ITEM SET QUANTITYONHAND=QUANTITYONHAND-ITEM4_QTY WHERE ITEMID=item4;
				END IF;
				IF item5_qty>0 then
					INSERT INTO orderdetails VALUES(new_order_id,item5,item5_qty);
					UPDATE ITEM SET QUANTITYONHAND=QUANTITYONHAND-ITEM1_QTY WHERE ITEMID=item1;
				END IF;
				DBMS_OUTPUT.PUT_LINE('ORDER SUCCESSFULLY CREATED');
			ELSE
				RAISE insufficient_quantity;
			END IF;
		else
			DBMS_OUTPUT.PUT_LINE('CONTRACT IS NOT VALID');
		END IF;
	ELSE
		RAISE no_customer_found;
		
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('ORDER CANNOT BE GENERATED');
	WHEN INSUFFICIENT_QUANTITY THEN
		DBMS_OUTPUT.PUT_LINE('INSUFFICIENT STOCK');
	WHEN NO_CUSTOMER_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('CUSTOMER NOT FOUND');
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('ERROR OCCURED WHILE CREATING ORDER');
END;
/
COMMIT;
-- FUNCTION
CREATE OR REPLACE FUNCTION CALCULATE_LATEFEE(bill_num NUMBER) RETURN NUMBER IS
	billamount number(7);
	no_of_days number;
	latefee number(7,2);
BEGIN
	SELECT totalbill,sysdate-datedue into billamount,no_of_days from bill where billid=bill_num and datepaid IS NULL;
	IF no_of_days>30 THEN
		latefee:= billamount*(0.10*(CEIL(no_of_days)/30));
	ELSE
		latefee:=0;
	END IF;
	RETURN latefee;
END;
/
-- TRIGGERS
-- 1. UPDATE BILL TRIGGER
CREATE OR REPLACE TRIGGER
	update_bill_billamount
AFTER UPDATE
ON bill
FOR EACH ROW
DECLARE
	BILL_DIFF NUMBER;
BEGIN
	IF :NEW.TOTALBILL < 0 THEN
		BILL_DIFF := :NEW.TOTALBILL;
	ELSE
		BILL_DIFF := :NEW.TOTALBILL - :OLD.TOTALBILL;
	END IF;
	DBMS_OUTPUT.PUT_LINE('The old bill amount was '||:old.totalbill);
	DBMS_OUTPUT.PUT_LINE('The new bill amount is '||:new.totalbill);
	DBMS_OUTPUT.PUT_LINE('The difference is '|| BILL_DIFF);
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		DBMS_OUTPUT.PUT_LINE('Data not found while updating bill');
	when others then
		dbms_output.put_line('Error in generate_bill trigger');
END;
/
COMMIT;

-- 2. RETURN ORDER TRIGGER
CREATE OR REPLACE TRIGGER
	return_order
AFTER UPDATE
ON orders
FOR EACH ROW
DECLARE
	BILL_ID NUMBER;
	bill_count number;
	bill_amount number;
	due_date date;
	c_itemid orderdetails.itemid%type;
	c_quantity orderdetails.quantity%type;
	cursor c_returnorder(order_id orderdetails.orderid%type) is
	SELECT itemid,quantity from orderdetails where orderid=order_id; 
BEGIN
	IF :NEW.RETURNEDBY IS NOT NULL AND :OLD.DATERETURNED IS NULL AND :NEW.DATERETURNED IS NOT NULL THEN
		SELECT billid,totalbill,datedue into bill_id,bill_amount,due_date FROM BILL WHERE ORDERID=:new.orderid;
		IF sql%found and bill_amount>0 and due_date - sysdate>=0 then
			update bill set totalbill= -1*bill_amount where billid=bill_id;
			DBMS_OUTPUT.PUT_LINE('BILL HAS BEEN UPDATED');
			OPEN c_returnorder(:new.orderid);
			LOOP
			FETCH c_returnorder into c_itemid,c_quantity;
				EXIT WHEN c_returnorder%NOTFOUND;
				UPDATE ITEM SET quantityonhand=quantityonhand+c_quantity where itemid=c_itemid;
				DBMS_OUTPUT.PUT_LINE('Order: ' ||:new.orderid||' item: '||c_itemid|| ' qty: '||c_quantity||' has been added back');
			END LOOP;
			CLOSE c_returnorder;
		ELSE
			DBMS_OUTPUT.PUT_LINE('YOU CANNOT RETURN THE ORDER');
		END IF;
	END IF;
EXCEPTION
	WHEN NO_DATA_FOUND THEN
		dbms_output.put_line('No Bill Found');
		RETURN;
	when OTHERS THEN
		ROLLBACK;
END;
/
COMMIT;


-- ROLES
-- CREATE ROLE ACCOUNTANT AND GRANT ACCESS TO SELECT,INSERT AND DELETE ON BILL TABLE
CREATE ROLE ACCOUNTANT;
GRANT SELECT,INSERT,UPDATE,DELETE ON BILL TO ACCOUNTANT;

-- CREATE ROLE DELIVERYMANAGER AND GRANT ACCESS TO ROUTE TABLE;
CREATE ROLE DELIVERYMANAGER;
GRANT SELECT,INSERT,UPDATE,DELETE on ROUTE TO DELIVERYMANAGER;
