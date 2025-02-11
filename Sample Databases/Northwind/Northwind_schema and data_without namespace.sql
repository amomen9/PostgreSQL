--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: airports; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE airports (
    id integer NOT NULL,
    code character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE airports OWNER TO admin;

--
-- Name: airports_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE airports_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE airports_id_seq OWNER TO admin;

--
-- Name: airports_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE airports_id_seq OWNED BY airports.id;


--
-- Name: categories; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE categories (
    id integer NOT NULL,
    category_name character varying(255),
    description character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE categories OWNER TO admin;

--
-- Name: categories_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE categories_id_seq OWNER TO admin;

--
-- Name: categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE categories_id_seq OWNED BY categories.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE customers (
    id integer NOT NULL,
    company_code character varying(255),
    company_name character varying(255),
    contact_name character varying(255),
    contact_title character varying(255),
    address character varying(255),
    city character varying(255),
    region character varying(255),
    postal_code character varying(255),
    country character varying(255),
    phone character varying(255),
    fax character varying(255),
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE customers OWNER TO admin;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE customers_id_seq OWNER TO admin;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE customers_id_seq OWNED BY customers.id;


--
-- Name: employees; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE employees (
    id integer NOT NULL,
    first_name character varying(255),
    last_name character varying(255),
    title character varying(255),
    title_of_courtesy character varying(255),
    birth_date date,
    hire_date date,
    address character varying(255),
    city character varying(255),
    region character varying(255),
    postal_code character varying(255),
    country character varying(255),
    home_phone character varying(255),
    extension character varying(255),
    notes text,
    reports_to_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE employees OWNER TO admin;

--
-- Name: employees_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE employees_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE employees_id_seq OWNER TO admin;

--
-- Name: employees_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE employees_id_seq OWNED BY employees.id;


--
-- Name: flights; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE flights (
    id integer NOT NULL,
    departure_id integer,
    arrival_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE flights OWNER TO admin;

--
-- Name: flights_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE flights_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE flights_id_seq OWNER TO admin;

--
-- Name: flights_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE flights_id_seq OWNED BY flights.id;


--
-- Name: friend_requests; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE friend_requests (
    id integer NOT NULL,
    friender_id integer,
    friendee_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE friend_requests OWNER TO admin;

--
-- Name: friend_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE friend_requests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE friend_requests_id_seq OWNER TO admin;

--
-- Name: friend_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE friend_requests_id_seq OWNED BY friend_requests.id;


--
-- Name: order_details; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE order_details (
    id integer NOT NULL,
    unit_price numeric,
    quantity integer,
    discount numeric,
    order_id integer,
    product_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE order_details OWNER TO admin;

--
-- Name: order_details_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE order_details_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE order_details_id_seq OWNER TO admin;

--
-- Name: order_details_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE order_details_id_seq OWNED BY order_details.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE orders (
    id integer NOT NULL,
    order_date date,
    required_date date,
    shipped_date date,
    ship_via_id integer,
    freight numeric,
    ship_name character varying(255),
    ship_address character varying(255),
    ship_city character varying(255),
    ship_region character varying(255),
    ship_postal_code character varying(255),
    ship_country character varying(255),
    customer_code character varying(255),
    customer_id integer,
    employee_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE orders OWNER TO admin;

--
-- Name: orders_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE orders_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE orders_id_seq OWNER TO admin;

--
-- Name: orders_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE orders_id_seq OWNED BY orders.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE products (
    id integer NOT NULL,
    product_name character varying(255),
    quantity_per_unit character varying(255),
    unit_price numeric,
    units_in_stock integer,
    units_on_order integer,
    reorder_level integer,
    discontinued boolean,
    supplier_id integer,
    category_id integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE products OWNER TO admin;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE products_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE products_id_seq OWNER TO admin;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE products_id_seq OWNED BY products.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying(255) NOT NULL
);


ALTER TABLE schema_migrations OWNER TO admin;

--
-- Name: users; Type: TABLE; Schema: public; Owner: admin; Tablespace: 
--

CREATE TABLE users (
    id integer NOT NULL,
    email character varying(255),
    fb character varying(255),
    insta character varying(255),
    twitter character varying(255),
    password_digest character varying(255),
    handle character varying(255),
    bio text,
    ie integer,
    sn integer,
    tf integer,
    pj integer,
    created_at timestamp without time zone,
    updated_at timestamp without time zone
);


ALTER TABLE users OWNER TO admin;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: admin
--

CREATE SEQUENCE users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE users_id_seq OWNER TO admin;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: admin
--

ALTER SEQUENCE users_id_seq OWNED BY users.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY airports ALTER COLUMN id SET DEFAULT nextval('airports_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY categories ALTER COLUMN id SET DEFAULT nextval('categories_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY customers ALTER COLUMN id SET DEFAULT nextval('customers_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY employees ALTER COLUMN id SET DEFAULT nextval('employees_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY flights ALTER COLUMN id SET DEFAULT nextval('flights_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY friend_requests ALTER COLUMN id SET DEFAULT nextval('friend_requests_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY order_details ALTER COLUMN id SET DEFAULT nextval('order_details_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY orders ALTER COLUMN id SET DEFAULT nextval('orders_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY products ALTER COLUMN id SET DEFAULT nextval('products_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: admin
--

ALTER TABLE ONLY users ALTER COLUMN id SET DEFAULT nextval('users_id_seq'::regclass);


--
-- Data for Name: airports; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY airports (id, code, created_at, updated_at) FROM stdin;
\.


--
-- Name: airports_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('airports_id_seq', 1, false);


--
-- Data for Name: categories; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY categories (id, category_name, description, created_at, updated_at) FROM stdin;
1	Beverages	Soft drinks, coffees, teas, beers, and ales	\N	\N
2	Condiments	Sweet and savory sauces, relishes, spreads, and seasonings	\N	\N
3	Confections	Desserts, candies, and sweet breads	\N	\N
4	Dairy Products	Cheeses	\N	\N
5	Grains/Cereals	Breads, crackers, pasta, and cereal	\N	\N
6	Meat/Poultry	Prepared meats	\N	\N
7	Produce	Dried fruit and bean curd	\N	\N
8	Seafood	Seaweed and fish	\N	\N
\.


--
-- Name: categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('categories_id_seq', 8, true);


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY customers (id, company_code, company_name, contact_name, contact_title, address, city, region, postal_code, country, phone, fax, created_at, updated_at) FROM stdin;
1	ALFKI	Alfreds Futterkiste	Maria Anders	Sales Representative	Obere Str. 57	Berlin	\N	12209	Germany	030-0074321	030-0076545	\N	\N
2	ANATR	Ana Trujillo Emparedados y helados	Ana Trujillo	Owner	Avda. de la Constitución 2222	México D.F.	\N	05021	Mexico	(5) 555-4729	(5) 555-3745	\N	\N
3	ANTON	Antonio Moreno Taquería	Antonio Moreno	Owner	Mataderos  2312	México D.F.	\N	05023	Mexico	(5) 555-3932	\N	\N	\N
4	AROUT	Around the Horn	Thomas Hardy	Sales Representative	120 Hanover Sq.	London	\N	WA1 1DP	UK	(171) 555-7788	(171) 555-6750	\N	\N
5	BERGS	Berglunds snabbköp	Christina Berglund	Order Administrator	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	0921-12 34 65	0921-12 34 67	\N	\N
6	BLAUS	Blauer See Delikatessen	Hanna Moos	Sales Representative	Forsterstr. 57	Mannheim	\N	68306	Germany	0621-08460	0621-08924	\N	\N
7	BLONP	Blondesddsl père et fils	Frédérique Citeaux	Marketing Manager	24, place Kléber	Strasbourg	\N	67000	France	88.60.15.31	88.60.15.32	\N	\N
8	BOLID	Bólido Comidas preparadas	Martín Sommer	Owner	C/ Araquil, 67	Madrid	\N	28023	Spain	(91) 555 22 82	(91) 555 91 99	\N	\N
9	BONAP	Bon app'	Laurence Lebihan	Owner	12, rue des Bouchers	Marseille	\N	13008	France	91.24.45.40	91.24.45.41	\N	\N
10	BOTTM	Bottom-Dollar Markets	Elizabeth Lincoln	Accounting Manager	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	(604) 555-4729	(604) 555-3745	\N	\N
11	BSBEV	B's Beverages	Victoria Ashworth	Sales Representative	Fauntleroy Circus	London	\N	EC2 5NT	UK	(171) 555-1212	\N	\N	\N
12	CACTU	Cactus Comidas para llevar	Patricio Simpson	Sales Agent	Cerrito 333	Buenos Aires	\N	1010	Argentina	(1) 135-5555	(1) 135-4892	\N	\N
13	CENTC	Centro comercial Moctezuma	Francisco Chang	Marketing Manager	Sierras de Granada 9993	México D.F.	\N	05022	Mexico	(5) 555-3392	(5) 555-7293	\N	\N
14	CHOPS	Chop-suey Chinese	Yang Wang	Owner	Hauptstr. 29	Bern	\N	3012	Switzerland	0452-076545	\N	\N	\N
15	COMMI	Comércio Mineiro	Pedro Afonso	Sales Associate	Av. dos Lusíadas, 23	Sao Paulo	SP	05432-043	Brazil	(11) 555-7647	\N	\N	\N
16	CONSH	Consolidated Holdings	Elizabeth Brown	Sales Representative	Berkeley Gardens 12  Brewery	London	\N	WX1 6LT	UK	(171) 555-2282	(171) 555-9199	\N	\N
17	DRACD	Drachenblut Delikatessen	Sven Ottlieb	Order Administrator	Walserweg 21	Aachen	\N	52066	Germany	0241-039123	0241-059428	\N	\N
18	DUMON	Du monde entier	Janine Labrune	Owner	67, rue des Cinquante Otages	Nantes	\N	44000	France	40.67.88.88	40.67.89.89	\N	\N
19	EASTC	Eastern Connection	Ann Devon	Sales Agent	35 King George	London	\N	WX3 6FW	UK	(171) 555-0297	(171) 555-3373	\N	\N
20	ERNSH	Ernst Handel	Roland Mendel	Sales Manager	Kirchgasse 6	Graz	\N	8010	Austria	7675-3425	7675-3426	\N	\N
21	FAMIA	Familia Arquibaldo	Aria Cruz	Marketing Assistant	Rua Orós, 92	Sao Paulo	SP	05442-030	Brazil	(11) 555-9857	\N	\N	\N
22	FISSA	FISSA Fabrica Inter. Salchichas S.A.	Diego Roel	Accounting Manager	C/ Moralzarzal, 86	Madrid	\N	28034	Spain	(91) 555 94 44	(91) 555 55 93	\N	\N
23	FOLIG	Folies gourmandes	Martine Rancé	Assistant Sales Agent	184, chaussée de Tournai	Lille	\N	59000	France	20.16.10.16	20.16.10.17	\N	\N
24	FOLKO	Folk och fä HB	Maria Larsson	Owner	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	0695-34 67 21	\N	\N	\N
25	FRANK	Frankenversand	Peter Franken	Marketing Manager	Berliner Platz 43	München	\N	80805	Germany	089-0877310	089-0877451	\N	\N
26	FRANR	France restauration	Carine Schmitt	Marketing Manager	54, rue Royale	Nantes	\N	44000	France	40.32.21.21	40.32.21.20	\N	\N
27	FRANS	Franchi S.p.A.	Paolo Accorti	Sales Representative	Via Monte Bianco 34	Torino	\N	10100	Italy	011-4988260	011-4988261	\N	\N
28	FURIB	Furia Bacalhau e Frutos do Mar	Lino Rodriguez	Sales Manager	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal	(1) 354-2534	(1) 354-2535	\N	\N
29	GALED	Galería del gastrónomo	Eduardo Saavedra	Marketing Manager	Rambla de Cataluña, 23	Barcelona	\N	08022	Spain	(93) 203 4560	(93) 203 4561	\N	\N
30	GODOS	Godos Cocina Típica	José Pedro Freyre	Sales Manager	C/ Romero, 33	Sevilla	\N	41101	Spain	(95) 555 82 82	\N	\N	\N
31	GOURL	Gourmet Lanchonetes	André Fonseca	Sales Associate	Av. Brasil, 442	Campinas	SP	04876-786	Brazil	(11) 555-9482	\N	\N	\N
32	GREAL	Great Lakes Food Market	Howard Snyder	Marketing Manager	2732 Baker Blvd.	Eugene	OR	97403	USA	(503) 555-7555	\N	\N	\N
33	GROSR	GROSELLA-Restaurante	Manuel Pereira	Owner	5ª Ave. Los Palos Grandes	Caracas	DF	1081	Venezuela	(2) 283-2951	(2) 283-3397	\N	\N
34	HANAR	Hanari Carnes	Mario Pontes	Accounting Manager	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	(21) 555-0091	(21) 555-8765	\N	\N
35	HILAA	HILARION-Abastos	Carlos Hernández	Sales Representative	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	(5) 555-1340	(5) 555-1948	\N	\N
36	HUNGC	Hungry Coyote Import Store	Yoshi Latimer	Sales Representative	City Center Plaza 516 Main St.	Elgin	OR	97827	USA	(503) 555-6874	(503) 555-2376	\N	\N
37	HUNGO	Hungry Owl All-Night Grocers	Patricia McKenna	Sales Associate	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	2967 542	2967 3333	\N	\N
38	ISLAT	Island Trading	Helen Bennett	Marketing Manager	Garden House Crowther Way	Cowes	Isle of Wight	PO31 7PJ	UK	(198) 555-8888	\N	\N	\N
39	KOENE	Königlich Essen	Philip Cramer	Sales Associate	Maubelstr. 90	Brandenburg	\N	14776	Germany	0555-09876	\N	\N	\N
40	LACOR	La corne d'abondance	Daniel Tonini	Sales Representative	67, avenue de l'Europe	Versailles	\N	78000	France	30.59.84.10	30.59.85.11	\N	\N
41	LAMAI	La maison d'Asie	Annette Roulet	Sales Manager	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	61.77.61.10	61.77.61.11	\N	\N
42	LAUGB	Laughing Bacchus Wine Cellars	Yoshi Tannamuri	Marketing Assistant	1900 Oak St.	Vancouver	BC	V3F 2K1	Canada	(604) 555-3392	(604) 555-7293	\N	\N
43	LAZYK	Lazy K Kountry Store	John Steel	Marketing Manager	12 Orchestra Terrace	Walla Walla	WA	99362	USA	(509) 555-7969	(509) 555-6221	\N	\N
44	LEHMS	Lehmanns Marktstand	Renate Messner	Sales Representative	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	069-0245984	069-0245874	\N	\N
45	LETSS	Let's Stop N Shop	Jaime Yorres	Owner	87 Polk St. Suite 5	San Francisco	CA	94117	USA	(415) 555-5938	\N	\N	\N
46	LILAS	LILA-Supermercado	Carlos González	Accounting Manager	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	(9) 331-6954	(9) 331-7256	\N	\N
47	LINOD	LINO-Delicateses	Felipe Izquierdo	Owner	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	(8) 34-56-12	(8) 34-93-93	\N	\N
48	LONEP	Lonesome Pine Restaurant	Fran Wilson	Sales Manager	89 Chiaroscuro Rd.	Portland	OR	97219	USA	(503) 555-9573	(503) 555-9646	\N	\N
49	MAGAA	Magazzini Alimentari Riuniti	Giovanni Rovelli	Marketing Manager	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy	035-640230	035-640231	\N	\N
50	MAISD	Maison Dewey	Catherine Dewey	Sales Agent	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium	(02) 201 24 67	(02) 201 24 68	\N	\N
51	MEREP	Mère Paillarde	Jean Fresnière	Marketing Assistant	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	(514) 555-8054	(514) 555-8055	\N	\N
52	MORGK	Morgenstern Gesundkost	Alexander Feuer	Marketing Assistant	Heerstr. 22	Leipzig	\N	04179	Germany	0342-023176	\N	\N	\N
53	NORTS	North/South	Simon Crowther	Sales Associate	South House 300 Queensbridge	London	\N	SW7 1RZ	UK	(171) 555-7733	(171) 555-2530	\N	\N
54	OCEAN	Océano Atlántico Ltda.	Yvonne Moncada	Sales Agent	Ing. Gustavo Moncada 8585 Piso 20-A	Buenos Aires	\N	1010	Argentina	(1) 135-5333	(1) 135-5535	\N	\N
55	OLDWO	Old World Delicatessen	Rene Phillips	Sales Representative	2743 Bering St.	Anchorage	AK	99508	USA	(907) 555-7584	(907) 555-2880	\N	\N
56	OTTIK	Ottilies Käseladen	Henriette Pfalzheim	Owner	Mehrheimerstr. 369	Köln	\N	50739	Germany	0221-0644327	0221-0765721	\N	\N
57	PARIS	Paris spécialités	Marie Bertrand	Owner	265, boulevard Charonne	Paris	\N	75012	France	(1) 42.34.22.66	(1) 42.34.22.77	\N	\N
58	PERIC	Pericles Comidas clásicas	Guillermo Fernández	Sales Representative	Calle Dr. Jorge Cash 321	México D.F.	\N	05033	Mexico	(5) 552-3745	(5) 545-3745	\N	\N
59	PICCO	Piccolo und mehr	Georg Pipps	Sales Manager	Geislweg 14	Salzburg	\N	5020	Austria	6562-9722	6562-9723	\N	\N
60	PRINI	Princesa Isabel Vinhos	Isabel de Castro	Sales Representative	Estrada da saúde n. 58	Lisboa	\N	1756	Portugal	(1) 356-5634	\N	\N	\N
61	QUEDE	Que Delícia	Bernardo Batista	Accounting Manager	Rua da Panificadora, 12	Rio de Janeiro	RJ	02389-673	Brazil	(21) 555-4252	(21) 555-4545	\N	\N
62	QUEEN	Queen Cozinha	Lúcia Carvalho	Marketing Assistant	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	(11) 555-1189	\N	\N	\N
63	QUICK	QUICK-Stop	Horst Kloss	Accounting Manager	Taucherstraße 10	Cunewalde	\N	01307	Germany	0372-035188	\N	\N	\N
64	RANCH	Rancho grande	Sergio Gutiérrez	Sales Representative	Av. del Libertador 900	Buenos Aires	\N	1010	Argentina	(1) 123-5555	(1) 123-5556	\N	\N
65	RATTC	Rattlesnake Canyon Grocery	Paula Wilson	Assistant Sales Representative	2817 Milton Dr.	Albuquerque	NM	87110	USA	(505) 555-5939	(505) 555-3620	\N	\N
66	REGGC	Reggiani Caseifici	Maurizio Moroni	Sales Associate	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	0522-556721	0522-556722	\N	\N
67	RICAR	Ricardo Adocicados	Janete Limeira	Assistant Sales Agent	Av. Copacabana, 267	Rio de Janeiro	RJ	02389-890	Brazil	(21) 555-3412	\N	\N	\N
68	RICSU	Richter Supermarkt	Michael Holz	Sales Manager	Grenzacherweg 237	Genève	\N	1203	Switzerland	0897-034214	\N	\N	\N
69	ROMEY	Romero y tomillo	Alejandra Camino	Accounting Manager	Gran Vía, 1	Madrid	\N	28001	Spain	(91) 745 6200	(91) 745 6210	\N	\N
70	SANTG	Santé Gourmet	Jonas Bergulfsen	Owner	Erling Skakkes gate 78	Stavern	\N	4110	Norway	07-98 92 35	07-98 92 47	\N	\N
71	SAVEA	Save-a-lot Markets	Jose Pavarotti	Sales Representative	187 Suffolk Ln.	Boise	ID	83720	USA	(208) 555-8097	\N	\N	\N
72	SEVES	Seven Seas Imports	Hari Kumar	Sales Manager	90 Wadhurst Rd.	London	\N	OX15 4NB	UK	(171) 555-1717	(171) 555-5646	\N	\N
73	SIMOB	Simons bistro	Jytte Petersen	Owner	Vinbæltet 34	Kobenhavn	\N	1734	Denmark	31 12 34 56	31 13 35 57	\N	\N
74	SPECD	Spécialités du monde	Dominique Perrier	Marketing Manager	25, rue Lauriston	Paris	\N	75016	France	(1) 47.55.60.10	(1) 47.55.60.20	\N	\N
75	SPLIR	Split Rail Beer & Ale	Art Braunschweiger	Sales Manager	P.O. Box 555	Lander	WY	82520	USA	(307) 555-4680	(307) 555-6525	\N	\N
76	SUPRD	Suprêmes délices	Pascale Cartrain	Accounting Manager	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	(071) 23 67 22 20	(071) 23 67 22 21	\N	\N
77	THEBI	The Big Cheese	Liz Nixon	Marketing Manager	89 Jefferson Way Suite 2	Portland	OR	97201	USA	(503) 555-3612	\N	\N	\N
78	THECR	The Cracker Box	Liu Wong	Marketing Assistant	55 Grizzly Peak Rd.	Butte	MT	59801	USA	(406) 555-5834	(406) 555-8083	\N	\N
79	TOMSP	Toms Spezialitäten	Karin Josephs	Marketing Manager	Luisenstr. 48	Münster	\N	44087	Germany	0251-031259	0251-035695	\N	\N
80	TORTU	Tortuga Restaurante	Miguel Angel Paolino	Owner	Avda. Azteca 123	México D.F.	\N	05033	Mexico	(5) 555-2933	\N	\N	\N
81	TRADH	Tradição Hipermercados	Anabela Domingues	Sales Representative	Av. Inês de Castro, 414	Sao Paulo	SP	05634-030	Brazil	(11) 555-2167	(11) 555-2168	\N	\N
82	TRAIH	Trail's Head Gourmet Provisioners	Helvetius Nagy	Sales Associate	722 DaVinci Blvd.	Kirkland	WA	98034	USA	(206) 555-8257	(206) 555-2174	\N	\N
83	VAFFE	Vaffeljernet	Palle Ibsen	Sales Manager	Smagsloget 45	Århus	\N	8200	Denmark	86 21 32 43	86 22 33 44	\N	\N
84	VICTE	Victuailles en stock	Mary Saveley	Sales Agent	2, rue du Commerce	Lyon	\N	69004	France	78.32.54.86	78.32.54.87	\N	\N
85	VINET	Vins et alcools Chevalier	Paul Henriot	Accounting Manager	59 rue de l'Abbaye	Reims	\N	51100	France	26.47.15.10	26.47.15.11	\N	\N
86	WANDK	Die Wandernde Kuh	Rita Müller	Sales Representative	Adenauerallee 900	Stuttgart	\N	70563	Germany	0711-020361	0711-035428	\N	\N
87	WARTH	Wartian Herkku	Pirkko Koskitalo	Accounting Manager	Torikatu 38	Oulu	\N	90110	Finland	981-443655	981-443655	\N	\N
88	WELLI	Wellington Importadora	Paula Parente	Sales Manager	Rua do Mercado, 12	Resende	SP	08737-363	Brazil	(14) 555-8122	\N	\N	\N
89	WHITC	White Clover Markets	Karl Jablonski	Owner	305 - 14th Ave. S. Suite 3B	Seattle	WA	98128	USA	(206) 555-4112	(206) 555-4115	\N	\N
90	WILMK	Wilman Kala	Matti Karttunen	Owner/Marketing Assistant	Keskuskatu 45	Helsinki	\N	21240	Finland	90-224 8858	90-224 8858	\N	\N
91	WOLZA	Wolski  Zajazd	Zbyszek Piestrzeniewicz	Owner	ul. Filtrowa 68	Warszawa	\N	01-012	Poland	(26) 642-7012	(26) 642-7012	\N	\N
\.


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('customers_id_seq', 91, true);


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY employees (id, first_name, last_name, title, title_of_courtesy, birth_date, hire_date, address, city, region, postal_code, country, home_phone, extension, notes, reports_to_id, created_at, updated_at) FROM stdin;
1	Nancy	Davolio	Sales Representative	Ms.	1948-12-08	1992-05-01	507 - 20th Ave. E.\\nApt. 2A	Seattle	WA	98122	USA	(206) 555-9857	5467	Education includes a BA in psychology from Colorado State University in 1970.  She also completed "The Art of the Cold Call."  Nancy is a member of Toastmasters International.	2	\N	\N
2	Andrew	Fuller	Vice President, Sales	Dr.	1952-02-19	1992-08-14	908 W. Capital Way	Tacoma	WA	98401	USA	(206) 555-9482	3457	Andrew received his BTS commercial in 1974 and a Ph.D. in international marketing from the University of Dallas in 1981.  He is fluent in French and Italian and reads German.  He joined the company as a sales representative, was promoted to sales manager in January 1992 and to vice president of sales in March 1993.  Andrew is a member of the Sales Management Roundtable, the Seattle Chamber of Commerce, and the Pacific Rim Importers Association.	\N	\N	\N
3	Janet	Leverling	Sales Representative	Ms.	1963-08-30	1992-04-01	722 Moss Bay Blvd.	Kirkland	WA	98033	USA	(206) 555-3412	3355	Janet has a BS degree in chemistry from Boston College (1984).  She has also completed a certificate program in food retailing management.  Janet was hired as a sales associate in 1991 and promoted to sales representative in February 1992.	2	\N	\N
4	Margaret	Peacock	Sales Representative	Mrs.	1937-09-19	1993-05-03	4110 Old Redmond Rd.	Redmond	WA	98052	USA	(206) 555-8122	5176	Margaret holds a BA in English literature from Concordia College (1958) and an MA from the American Institute of Culinary Arts (1966).  She was assigned to the London office temporarily from July through November 1992.	2	\N	\N
5	Steven	Buchanan	Sales Manager	Mr.	1955-03-04	1993-10-17	14 Garrett Hill	London	\N	SW1 8JR	UK	(71) 555-4848	3453	Steven Buchanan graduated from St. Andrews University, Scotland, with a BSC degree in 1976.  Upon joining the company as a sales representative in 1992, he spent 6 months in an orientation program at the Seattle office and then returned to his permanent post in London.  He was promoted to sales manager in March 1993.  Mr. Buchanan has completed the courses "Successful Telemarketing" and "International Sales Management."  He is fluent in French.	2	\N	\N
6	Michael	Suyama	Sales Representative	Mr.	1963-07-02	1993-10-17	Coventry House\\nMiner Rd.	London	\N	EC2 7JR	UK	(71) 555-7773	428	Michael is a graduate of Sussex University (MA, economics, 1983) and the University of California at Los Angeles (MBA, marketing, 1986).  He has also taken the courses "Multi-Cultural Selling" and "Time Management for the Sales Professional."  He is fluent in Japanese and can read and write French, Portuguese, and Spanish.	5	\N	\N
7	Robert	King	Sales Representative	Mr.	1960-05-29	1994-01-02	Edgeham Hollow\\nWinchester Way	London	\N	RG1 9SP	UK	(71) 555-5598	465	Robert King served in the Peace Corps and traveled extensively before completing his degree in English at the University of Michigan in 1992, the year he joined the company.  After completing a course entitled "Selling in Europe," he was transferred to the London office in March 1993.	5	\N	\N
8	Laura	Callahan	Inside Sales Coordinator	Ms.	1958-01-09	1994-03-05	4726 - 11th Ave. N.E.	Seattle	WA	98105	USA	(206) 555-1189	2344	Laura received a BA in psychology from the University of Washington.  She has also completed a course in business French.  She reads and writes French.	2	\N	\N
9	Anne	Dodsworth	Sales Representative	Ms.	1966-01-27	1994-11-15	7 Houndstooth Rd.	London	\N	WG2 7LT	UK	(71) 555-4444	452	Anne has a BA degree in English from St. Lawrence College.  She is fluent in French and German.	5	\N	\N
\.


--
-- Name: employees_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('employees_id_seq', 9, true);


--
-- Data for Name: flights; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY flights (id, departure_id, arrival_id, created_at, updated_at) FROM stdin;
\.


--
-- Name: flights_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('flights_id_seq', 1, false);


--
-- Data for Name: friend_requests; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY friend_requests (id, friender_id, friendee_id, created_at, updated_at) FROM stdin;
\.


--
-- Name: friend_requests_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('friend_requests_id_seq', 1, false);


--
-- Data for Name: order_details; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY order_details (id, unit_price, quantity, discount, order_id, product_id, created_at, updated_at) FROM stdin;
1	34.80	5	0.00	10248	72	\N	\N
2	9.80	10	0.00	10248	42	\N	\N
3	14.00	12	0.00	10248	11	\N	\N
4	42.40	40	0.00	10249	51	\N	\N
5	18.60	9	0.00	10249	14	\N	\N
6	16.80	15	0.15	10250	65	\N	\N
7	42.40	35	0.15	10250	51	\N	\N
8	7.70	10	0.00	10250	41	\N	\N
9	16.80	20	0.00	10251	65	\N	\N
10	15.60	15	0.05	10251	57	\N	\N
11	16.80	6	0.05	10251	22	\N	\N
12	27.20	40	0.00	10252	60	\N	\N
13	2.00	25	0.05	10252	33	\N	\N
14	64.80	40	0.05	10252	20	\N	\N
15	16.00	40	0.00	10253	49	\N	\N
16	14.40	42	0.00	10253	39	\N	\N
17	10.00	20	0.00	10253	31	\N	\N
18	8.00	21	0.00	10254	74	\N	\N
19	19.20	21	0.15	10254	55	\N	\N
20	3.60	15	0.15	10254	24	\N	\N
21	44.00	30	0.00	10255	59	\N	\N
22	15.20	25	0.00	10255	36	\N	\N
23	13.90	35	0.00	10255	16	\N	\N
24	15.20	20	0.00	10255	2	\N	\N
25	10.40	12	0.00	10256	77	\N	\N
26	26.20	15	0.00	10256	53	\N	\N
27	10.40	15	0.00	10257	77	\N	\N
28	14.40	6	0.00	10257	39	\N	\N
29	35.10	25	0.00	10257	27	\N	\N
30	25.60	6	0.20	10258	32	\N	\N
31	17.00	65	0.20	10258	5	\N	\N
32	15.20	50	0.20	10258	2	\N	\N
33	20.80	1	0.00	10259	37	\N	\N
34	8.00	10	0.00	10259	21	\N	\N
35	12.00	21	0.25	10260	70	\N	\N
36	39.40	15	0.25	10260	62	\N	\N
37	15.60	50	0.00	10260	57	\N	\N
38	7.70	16	0.25	10260	41	\N	\N
39	14.40	20	0.00	10261	35	\N	\N
40	8.00	20	0.00	10261	21	\N	\N
41	30.40	2	0.00	10262	56	\N	\N
42	24.00	15	0.00	10262	7	\N	\N
43	17.00	12	0.20	10262	5	\N	\N
44	8.00	36	0.25	10263	74	\N	\N
45	20.70	60	0.25	10263	30	\N	\N
46	3.60	28	0.00	10263	24	\N	\N
47	13.90	60	0.25	10263	16	\N	\N
48	7.70	25	0.15	10264	41	\N	\N
49	15.20	35	0.00	10264	2	\N	\N
50	12.00	20	0.00	10265	70	\N	\N
51	31.20	30	0.00	10265	17	\N	\N
52	30.40	12	0.05	10266	12	\N	\N
53	14.40	15	0.15	10267	76	\N	\N
54	44.00	70	0.15	10267	59	\N	\N
55	14.70	50	0.00	10267	40	\N	\N
56	27.80	4	0.00	10268	72	\N	\N
57	99.00	10	0.00	10268	29	\N	\N
58	27.80	20	0.05	10269	72	\N	\N
59	2.00	60	0.05	10269	33	\N	\N
60	36.80	25	0.00	10270	43	\N	\N
61	15.20	30	0.00	10270	36	\N	\N
62	2.00	24	0.00	10271	33	\N	\N
63	27.80	24	0.00	10272	72	\N	\N
64	10.00	40	0.00	10272	31	\N	\N
65	64.80	6	0.00	10272	20	\N	\N
66	14.40	33	0.05	10273	76	\N	\N
67	14.70	60	0.05	10273	40	\N	\N
68	2.00	20	0.00	10273	33	\N	\N
69	10.00	15	0.05	10273	31	\N	\N
70	24.80	24	0.05	10273	10	\N	\N
71	27.80	7	0.00	10274	72	\N	\N
72	17.20	20	0.00	10274	71	\N	\N
73	44.00	6	0.05	10275	59	\N	\N
74	3.60	12	0.05	10275	24	\N	\N
75	4.80	10	0.00	10276	13	\N	\N
76	24.80	15	0.00	10276	10	\N	\N
77	39.40	12	0.00	10277	62	\N	\N
78	36.40	20	0.00	10277	28	\N	\N
79	12.00	25	0.00	10278	73	\N	\N
80	35.10	8	0.00	10278	63	\N	\N
81	44.00	15	0.00	10278	59	\N	\N
82	15.50	16	0.00	10278	44	\N	\N
83	31.20	15	0.25	10279	17	\N	\N
84	6.20	30	0.00	10280	75	\N	\N
85	19.20	20	0.00	10280	55	\N	\N
86	3.60	12	0.00	10280	24	\N	\N
87	14.40	4	0.00	10281	35	\N	\N
88	3.60	6	0.00	10281	24	\N	\N
89	7.30	1	0.00	10281	19	\N	\N
90	15.60	2	0.00	10282	57	\N	\N
91	20.70	6	0.00	10282	30	\N	\N
92	27.80	3	0.00	10283	72	\N	\N
93	27.20	35	0.00	10283	60	\N	\N
94	7.30	18	0.00	10283	19	\N	\N
95	12.40	20	0.00	10283	15	\N	\N
96	11.20	5	0.25	10284	67	\N	\N
97	27.20	20	0.25	10284	60	\N	\N
98	15.50	21	0.00	10284	44	\N	\N
99	35.10	15	0.25	10284	27	\N	\N
100	26.20	36	0.20	10285	53	\N	\N
101	14.70	40	0.20	10285	40	\N	\N
102	14.40	45	0.20	10285	1	\N	\N
103	39.40	40	0.00	10286	62	\N	\N
104	14.40	100	0.00	10286	35	\N	\N
105	9.60	15	0.15	10287	46	\N	\N
106	11.20	20	0.00	10287	34	\N	\N
107	13.90	40	0.15	10287	16	\N	\N
108	10.00	3	0.10	10288	68	\N	\N
109	5.90	10	0.10	10288	54	\N	\N
110	26.60	9	0.00	10289	64	\N	\N
111	8.00	30	0.00	10289	3	\N	\N
112	10.40	10	0.00	10290	77	\N	\N
113	16.00	15	0.00	10290	49	\N	\N
114	99.00	15	0.00	10290	29	\N	\N
115	17.00	20	0.00	10290	5	\N	\N
116	42.40	2	0.10	10291	51	\N	\N
117	15.50	24	0.10	10291	44	\N	\N
118	4.80	20	0.10	10291	13	\N	\N
119	64.80	20	0.00	10292	20	\N	\N
120	6.20	6	0.00	10293	75	\N	\N
121	35.10	5	0.00	10293	63	\N	\N
122	3.60	10	0.00	10293	24	\N	\N
123	50.00	12	0.00	10293	18	\N	\N
124	6.20	6	0.00	10294	75	\N	\N
125	27.20	21	0.00	10294	60	\N	\N
126	36.80	15	0.00	10294	43	\N	\N
127	31.20	15	0.00	10294	17	\N	\N
128	14.40	18	0.00	10294	1	\N	\N
129	30.40	4	0.00	10295	56	\N	\N
130	28.80	15	0.00	10296	69	\N	\N
131	13.90	30	0.00	10296	16	\N	\N
132	16.80	12	0.00	10296	11	\N	\N
133	27.80	20	0.00	10297	72	\N	\N
134	14.40	60	0.00	10297	39	\N	\N
135	39.40	15	0.00	10298	62	\N	\N
136	44.00	30	0.25	10298	59	\N	\N
137	15.20	40	0.25	10298	36	\N	\N
138	15.20	40	0.00	10298	2	\N	\N
139	12.00	20	0.00	10299	70	\N	\N
140	7.30	15	0.00	10299	19	\N	\N
141	10.00	20	0.00	10300	68	\N	\N
142	13.60	30	0.00	10300	66	\N	\N
143	30.40	20	0.00	10301	56	\N	\N
144	14.70	10	0.00	10301	40	\N	\N
145	36.80	12	0.00	10302	43	\N	\N
146	36.40	28	0.00	10302	28	\N	\N
147	31.20	40	0.00	10302	17	\N	\N
148	10.00	15	0.10	10303	68	\N	\N
149	16.80	30	0.10	10303	65	\N	\N
150	14.70	40	0.10	10303	40	\N	\N
151	17.20	2	0.00	10304	71	\N	\N
152	44.00	10	0.00	10304	59	\N	\N
153	16.00	30	0.00	10304	49	\N	\N
154	14.40	30	0.10	10305	39	\N	\N
155	99.00	25	0.10	10305	29	\N	\N
156	50.00	25	0.10	10305	18	\N	\N
157	5.90	5	0.00	10306	54	\N	\N
158	26.20	10	0.00	10306	53	\N	\N
159	20.70	10	0.00	10306	30	\N	\N
160	10.00	3	0.00	10307	68	\N	\N
161	39.40	10	0.00	10307	62	\N	\N
162	12.00	5	0.00	10308	70	\N	\N
163	28.80	1	0.00	10308	69	\N	\N
164	17.20	3	0.00	10309	71	\N	\N
165	36.80	20	0.00	10309	43	\N	\N
166	11.20	2	0.00	10309	42	\N	\N
167	20.00	30	0.00	10309	6	\N	\N
168	17.60	20	0.00	10309	4	\N	\N
169	39.40	5	0.00	10310	62	\N	\N
170	13.90	10	0.00	10310	16	\N	\N
171	28.80	7	0.00	10311	69	\N	\N
172	11.20	6	0.00	10311	42	\N	\N
173	6.20	10	0.00	10312	75	\N	\N
174	26.20	20	0.00	10312	53	\N	\N
175	36.80	24	0.00	10312	43	\N	\N
176	36.40	4	0.00	10312	28	\N	\N
177	15.20	12	0.00	10313	36	\N	\N
178	39.40	25	0.10	10314	62	\N	\N
179	10.60	30	0.10	10314	58	\N	\N
180	25.60	40	0.10	10314	32	\N	\N
181	12.00	30	0.00	10315	70	\N	\N
182	11.20	14	0.00	10315	34	\N	\N
183	39.40	70	0.00	10316	62	\N	\N
184	7.70	10	0.00	10316	41	\N	\N
185	14.40	20	0.00	10317	1	\N	\N
186	14.40	6	0.00	10318	76	\N	\N
187	7.70	20	0.00	10318	41	\N	\N
188	14.40	30	0.00	10319	76	\N	\N
189	36.40	14	0.00	10319	28	\N	\N
190	31.20	8	0.00	10319	17	\N	\N
191	17.20	30	0.00	10320	71	\N	\N
192	14.40	10	0.00	10321	35	\N	\N
193	5.60	20	0.00	10322	52	\N	\N
194	14.40	4	0.00	10323	39	\N	\N
195	11.20	4	0.00	10323	25	\N	\N
196	12.40	5	0.00	10323	15	\N	\N
197	35.10	80	0.15	10324	63	\N	\N
198	44.00	40	0.15	10324	59	\N	\N
199	9.60	30	0.00	10324	46	\N	\N
200	14.40	70	0.15	10324	35	\N	\N
201	13.90	21	0.15	10324	16	\N	\N
202	27.80	40	0.00	10325	72	\N	\N
203	10.00	4	0.00	10325	31	\N	\N
204	18.60	9	0.00	10325	14	\N	\N
205	4.80	12	0.00	10325	13	\N	\N
206	20.00	6	0.00	10325	6	\N	\N
207	6.20	50	0.00	10326	75	\N	\N
208	15.60	16	0.00	10326	57	\N	\N
209	17.60	24	0.00	10326	4	\N	\N
210	10.60	30	0.20	10327	58	\N	\N
211	20.70	35	0.20	10327	30	\N	\N
212	16.80	50	0.20	10327	11	\N	\N
213	15.20	25	0.20	10327	2	\N	\N
214	10.00	10	0.00	10328	68	\N	\N
215	16.80	40	0.00	10328	65	\N	\N
216	44.00	9	0.00	10328	59	\N	\N
217	30.40	12	0.05	10329	56	\N	\N
218	210.80	20	0.05	10329	38	\N	\N
219	20.70	8	0.05	10329	30	\N	\N
220	7.30	10	0.05	10329	19	\N	\N
221	27.80	25	0.15	10330	72	\N	\N
222	24.90	50	0.15	10330	26	\N	\N
223	5.90	15	0.00	10331	54	\N	\N
224	7.60	16	0.20	10332	47	\N	\N
225	11.20	10	0.20	10332	42	\N	\N
226	50.00	40	0.20	10332	18	\N	\N
227	17.20	40	0.10	10333	71	\N	\N
228	8.00	10	0.10	10333	21	\N	\N
229	18.60	10	0.00	10333	14	\N	\N
230	10.00	10	0.00	10334	68	\N	\N
231	5.60	8	0.00	10334	52	\N	\N
232	42.40	48	0.20	10335	51	\N	\N
233	25.60	6	0.20	10335	32	\N	\N
234	10.00	25	0.20	10335	31	\N	\N
235	15.20	7	0.20	10335	2	\N	\N
236	17.60	18	0.10	10336	4	\N	\N
237	27.80	25	0.00	10337	72	\N	\N
238	20.80	28	0.00	10337	37	\N	\N
239	15.20	20	0.00	10337	36	\N	\N
240	24.90	24	0.00	10337	26	\N	\N
241	7.20	40	0.00	10337	23	\N	\N
242	20.70	15	0.00	10338	30	\N	\N
243	31.20	20	0.00	10338	17	\N	\N
244	39.40	28	0.00	10339	62	\N	\N
245	31.20	70	0.05	10339	17	\N	\N
246	17.60	10	0.00	10339	4	\N	\N
247	36.80	40	0.05	10340	43	\N	\N
248	7.70	12	0.05	10340	41	\N	\N
249	50.00	20	0.05	10340	18	\N	\N
250	44.00	9	0.15	10341	59	\N	\N
251	2.00	8	0.00	10341	33	\N	\N
252	19.20	40	0.20	10342	55	\N	\N
253	15.20	40	0.20	10342	36	\N	\N
254	10.00	56	0.20	10342	31	\N	\N
255	15.20	24	0.20	10342	2	\N	\N
256	14.40	15	0.00	10343	76	\N	\N
257	10.00	4	0.05	10343	68	\N	\N
258	26.60	50	0.00	10343	64	\N	\N
259	32.00	70	0.25	10344	8	\N	\N
260	17.60	35	0.00	10344	4	\N	\N
261	11.20	9	0.00	10345	42	\N	\N
262	7.30	80	0.00	10345	19	\N	\N
263	32.00	70	0.00	10345	8	\N	\N
264	30.40	20	0.00	10346	56	\N	\N
265	31.20	36	0.10	10346	17	\N	\N
266	6.20	6	0.15	10347	75	\N	\N
267	14.70	4	0.00	10347	40	\N	\N
268	14.40	50	0.15	10347	39	\N	\N
269	11.20	10	0.00	10347	25	\N	\N
270	7.20	25	0.00	10348	23	\N	\N
271	14.40	15	0.15	10348	1	\N	\N
272	5.90	24	0.00	10349	54	\N	\N
273	28.80	18	0.10	10350	69	\N	\N
274	13.00	15	0.10	10350	50	\N	\N
275	16.80	10	0.05	10351	65	\N	\N
276	15.50	77	0.05	10351	44	\N	\N
277	7.70	13	0.00	10351	41	\N	\N
278	210.80	20	0.05	10351	38	\N	\N
279	5.90	20	0.15	10352	54	\N	\N
280	3.60	10	0.00	10352	24	\N	\N
281	210.80	50	0.20	10353	38	\N	\N
282	16.80	12	0.20	10353	11	\N	\N
283	99.00	4	0.00	10354	29	\N	\N
284	14.40	12	0.00	10354	1	\N	\N
285	15.60	25	0.00	10355	57	\N	\N
286	3.60	25	0.00	10355	24	\N	\N
287	28.80	20	0.00	10356	69	\N	\N
288	19.20	12	0.00	10356	55	\N	\N
289	10.00	30	0.00	10356	31	\N	\N
290	27.20	8	0.20	10357	60	\N	\N
291	24.90	16	0.00	10357	26	\N	\N
292	24.80	30	0.20	10357	10	\N	\N
293	15.20	20	0.05	10358	36	\N	\N
294	11.20	10	0.05	10358	34	\N	\N
295	3.60	10	0.05	10358	24	\N	\N
296	27.20	80	0.05	10359	60	\N	\N
297	10.00	70	0.05	10359	31	\N	\N
298	13.90	56	0.05	10359	16	\N	\N
299	5.90	28	0.00	10360	54	\N	\N
300	16.00	35	0.00	10360	49	\N	\N
301	210.80	10	0.00	10360	38	\N	\N
302	99.00	35	0.00	10360	29	\N	\N
303	36.40	30	0.00	10360	28	\N	\N
304	27.20	55	0.10	10361	60	\N	\N
305	14.40	54	0.10	10361	39	\N	\N
306	5.90	24	0.00	10362	54	\N	\N
307	42.40	20	0.00	10362	51	\N	\N
308	11.20	50	0.00	10362	25	\N	\N
309	14.40	12	0.00	10363	76	\N	\N
310	6.20	12	0.00	10363	75	\N	\N
311	10.00	20	0.00	10363	31	\N	\N
312	17.20	5	0.00	10364	71	\N	\N
313	28.80	30	0.00	10364	69	\N	\N
314	16.80	24	0.00	10365	11	\N	\N
315	10.40	5	0.00	10366	77	\N	\N
316	16.80	5	0.00	10366	65	\N	\N
317	10.40	7	0.00	10367	77	\N	\N
318	16.80	15	0.00	10367	65	\N	\N
319	5.90	18	0.00	10367	54	\N	\N
320	11.20	36	0.00	10367	34	\N	\N
321	26.60	35	0.10	10368	64	\N	\N
322	15.60	25	0.00	10368	57	\N	\N
323	36.40	13	0.10	10368	28	\N	\N
324	8.00	5	0.10	10368	21	\N	\N
325	30.40	18	0.25	10369	56	\N	\N
326	99.00	20	0.00	10369	29	\N	\N
327	8.00	20	0.15	10370	74	\N	\N
328	26.60	30	0.00	10370	64	\N	\N
329	14.40	15	0.15	10370	1	\N	\N
330	15.20	6	0.20	10371	36	\N	\N
331	27.80	42	0.25	10372	72	\N	\N
332	27.20	70	0.25	10372	60	\N	\N
333	210.80	40	0.25	10372	38	\N	\N
334	64.80	12	0.25	10372	20	\N	\N
335	17.20	50	0.20	10373	71	\N	\N
336	10.60	80	0.20	10373	58	\N	\N
337	10.60	15	0.00	10374	58	\N	\N
338	10.00	30	0.00	10374	31	\N	\N
339	5.90	10	0.00	10375	54	\N	\N
340	18.60	15	0.00	10375	14	\N	\N
341	10.00	42	0.05	10376	31	\N	\N
342	14.40	20	0.15	10377	39	\N	\N
343	36.40	20	0.15	10377	28	\N	\N
344	17.20	6	0.00	10378	71	\N	\N
345	16.80	20	0.10	10379	65	\N	\N
346	35.10	16	0.10	10379	63	\N	\N
347	7.70	8	0.10	10379	41	\N	\N
348	12.00	30	0.00	10380	70	\N	\N
349	27.20	6	0.10	10380	60	\N	\N
350	26.20	20	0.10	10380	53	\N	\N
351	20.70	18	0.10	10380	30	\N	\N
352	8.00	14	0.00	10381	74	\N	\N
353	8.00	50	0.00	10382	74	\N	\N
354	2.00	60	0.00	10382	33	\N	\N
355	99.00	14	0.00	10382	29	\N	\N
356	50.00	9	0.00	10382	18	\N	\N
357	17.00	32	0.00	10382	5	\N	\N
358	30.40	20	0.00	10383	56	\N	\N
359	13.00	15	0.00	10383	50	\N	\N
360	4.80	20	0.00	10383	13	\N	\N
361	27.20	15	0.00	10384	60	\N	\N
362	64.80	28	0.00	10384	20	\N	\N
363	10.00	8	0.20	10385	68	\N	\N
364	27.20	20	0.20	10385	60	\N	\N
365	24.00	10	0.20	10385	7	\N	\N
366	11.20	10	0.00	10386	34	\N	\N
367	3.60	15	0.00	10386	24	\N	\N
368	17.20	15	0.00	10387	71	\N	\N
369	44.00	12	0.00	10387	59	\N	\N
370	36.40	6	0.00	10387	28	\N	\N
371	3.60	15	0.00	10387	24	\N	\N
372	26.20	40	0.00	10388	53	\N	\N
373	5.60	20	0.20	10388	52	\N	\N
374	7.60	15	0.20	10388	45	\N	\N
375	12.00	30	0.00	10389	70	\N	\N
376	39.40	20	0.00	10389	62	\N	\N
377	19.20	15	0.00	10389	55	\N	\N
378	24.80	16	0.00	10389	10	\N	\N
379	27.80	24	0.10	10390	72	\N	\N
380	9.60	45	0.00	10390	46	\N	\N
381	14.40	40	0.10	10390	35	\N	\N
382	10.00	60	0.10	10390	31	\N	\N
383	4.80	18	0.00	10391	13	\N	\N
384	28.80	50	0.00	10392	69	\N	\N
385	10.00	32	0.00	10393	31	\N	\N
386	24.90	70	0.25	10393	26	\N	\N
387	11.20	7	0.25	10393	25	\N	\N
388	18.60	42	0.25	10393	14	\N	\N
389	15.20	25	0.25	10393	2	\N	\N
390	39.40	10	0.00	10394	62	\N	\N
391	4.80	10	0.00	10394	13	\N	\N
392	28.80	8	0.00	10395	69	\N	\N
393	26.20	70	0.10	10395	53	\N	\N
394	9.60	28	0.10	10395	46	\N	\N
395	27.80	21	0.00	10396	72	\N	\N
396	17.20	60	0.00	10396	71	\N	\N
397	7.20	40	0.00	10396	23	\N	\N
398	42.40	18	0.15	10397	51	\N	\N
399	8.00	10	0.15	10397	21	\N	\N
400	19.20	120	0.10	10398	55	\N	\N
401	14.40	30	0.00	10398	35	\N	\N
402	10.40	14	0.00	10399	77	\N	\N
403	14.40	35	0.00	10399	76	\N	\N
404	17.20	30	0.00	10399	71	\N	\N
405	10.00	60	0.00	10399	68	\N	\N
406	16.00	30	0.00	10400	49	\N	\N
407	14.40	35	0.00	10400	35	\N	\N
408	99.00	21	0.00	10400	29	\N	\N
409	17.20	60	0.00	10401	71	\N	\N
410	16.80	20	0.00	10401	65	\N	\N
411	30.40	70	0.00	10401	56	\N	\N
412	20.70	18	0.00	10401	30	\N	\N
413	35.10	65	0.00	10402	63	\N	\N
414	7.20	60	0.00	10402	23	\N	\N
415	10.20	70	0.15	10403	48	\N	\N
416	13.90	21	0.15	10403	16	\N	\N
417	16.00	30	0.05	10404	49	\N	\N
418	11.20	40	0.05	10404	42	\N	\N
419	24.90	30	0.05	10404	26	\N	\N
420	8.00	50	0.00	10405	3	\N	\N
421	14.70	2	0.10	10406	40	\N	\N
422	15.20	5	0.10	10406	36	\N	\N
423	36.40	42	0.10	10406	28	\N	\N
424	8.00	30	0.10	10406	21	\N	\N
425	14.40	10	0.00	10406	1	\N	\N
426	17.20	15	0.00	10407	71	\N	\N
427	28.80	15	0.00	10407	69	\N	\N
428	16.80	30	0.00	10407	11	\N	\N
429	39.40	35	0.00	10408	62	\N	\N
430	5.90	6	0.00	10408	54	\N	\N
431	20.80	10	0.00	10408	37	\N	\N
432	8.00	12	0.00	10409	21	\N	\N
433	18.60	12	0.00	10409	14	\N	\N
434	44.00	16	0.00	10410	59	\N	\N
435	2.00	49	0.00	10410	33	\N	\N
436	44.00	9	0.20	10411	59	\N	\N
437	15.50	40	0.20	10411	44	\N	\N
438	7.70	25	0.20	10411	41	\N	\N
439	18.60	20	0.10	10412	14	\N	\N
440	14.40	14	0.00	10413	76	\N	\N
441	39.40	40	0.00	10413	62	\N	\N
442	14.40	24	0.00	10413	1	\N	\N
443	2.00	50	0.00	10414	33	\N	\N
444	7.30	18	0.05	10414	19	\N	\N
445	2.00	20	0.00	10415	33	\N	\N
446	31.20	2	0.00	10415	17	\N	\N
447	15.60	20	0.00	10416	57	\N	\N
448	26.20	10	0.00	10416	53	\N	\N
449	7.30	20	0.00	10416	19	\N	\N
450	10.40	35	0.00	10417	77	\N	\N
451	10.00	36	0.25	10417	68	\N	\N
452	9.60	2	0.25	10417	46	\N	\N
453	210.80	50	0.00	10417	38	\N	\N
454	8.00	15	0.00	10418	74	\N	\N
455	22.80	16	0.00	10418	61	\N	\N
456	7.60	55	0.00	10418	47	\N	\N
457	15.20	60	0.00	10418	2	\N	\N
458	28.80	20	0.05	10419	69	\N	\N
459	27.20	60	0.05	10419	60	\N	\N
460	12.00	20	0.10	10420	73	\N	\N
461	12.00	8	0.10	10420	70	\N	\N
462	4.80	2	0.10	10420	13	\N	\N
463	77.60	20	0.10	10420	9	\N	\N
464	10.40	10	0.15	10421	77	\N	\N
465	26.20	15	0.15	10421	53	\N	\N
466	24.90	30	0.00	10421	26	\N	\N
467	7.30	4	0.15	10421	19	\N	\N
468	24.90	2	0.00	10422	26	\N	\N
469	44.00	20	0.00	10423	59	\N	\N
470	10.00	14	0.00	10423	31	\N	\N
471	10.00	30	0.20	10424	68	\N	\N
472	210.80	49	0.20	10424	38	\N	\N
473	14.40	60	0.20	10424	35	\N	\N
474	14.40	20	0.25	10425	76	\N	\N
475	19.20	10	0.25	10425	55	\N	\N
476	26.60	7	0.00	10426	64	\N	\N
477	30.40	5	0.00	10426	56	\N	\N
478	18.60	35	0.00	10427	14	\N	\N
479	9.60	20	0.00	10428	46	\N	\N
480	35.10	35	0.25	10429	63	\N	\N
481	13.00	40	0.00	10429	50	\N	\N
482	44.00	70	0.20	10430	59	\N	\N
483	30.40	30	0.00	10430	56	\N	\N
484	8.00	50	0.00	10430	21	\N	\N
485	31.20	45	0.20	10430	17	\N	\N
486	7.60	30	0.25	10431	47	\N	\N
487	14.70	50	0.25	10431	40	\N	\N
488	31.20	50	0.25	10431	17	\N	\N
489	5.90	40	0.00	10432	54	\N	\N
490	24.90	10	0.00	10432	26	\N	\N
491	30.40	28	0.00	10433	56	\N	\N
492	14.40	18	0.15	10434	76	\N	\N
493	16.80	6	0.00	10434	11	\N	\N
494	27.80	10	0.00	10435	72	\N	\N
495	16.80	12	0.00	10435	22	\N	\N
496	15.20	10	0.00	10435	2	\N	\N
497	6.20	24	0.10	10436	75	\N	\N
498	26.60	30	0.10	10436	64	\N	\N
499	30.40	40	0.10	10436	56	\N	\N
500	9.60	5	0.00	10436	46	\N	\N
501	26.20	15	0.00	10437	53	\N	\N
502	15.60	15	0.20	10438	57	\N	\N
503	11.20	20	0.20	10438	34	\N	\N
504	7.30	15	0.20	10438	19	\N	\N
505	8.00	30	0.00	10439	74	\N	\N
506	26.60	6	0.00	10439	64	\N	\N
507	13.90	16	0.00	10439	16	\N	\N
508	30.40	15	0.00	10439	12	\N	\N
509	22.80	90	0.15	10440	61	\N	\N
510	99.00	24	0.15	10440	29	\N	\N
511	13.90	49	0.15	10440	16	\N	\N
512	15.20	45	0.15	10440	2	\N	\N
513	35.10	50	0.00	10441	27	\N	\N
514	13.60	60	0.00	10442	66	\N	\N
515	5.90	80	0.00	10442	54	\N	\N
516	16.80	30	0.00	10442	11	\N	\N
517	36.40	12	0.00	10443	28	\N	\N
518	16.80	6	0.20	10443	11	\N	\N
519	7.70	30	0.00	10444	41	\N	\N
520	14.40	8	0.00	10444	35	\N	\N
521	24.90	15	0.00	10444	26	\N	\N
522	31.20	10	0.00	10444	17	\N	\N
523	5.90	15	0.00	10445	54	\N	\N
524	14.40	6	0.00	10445	39	\N	\N
525	5.60	15	0.10	10446	52	\N	\N
526	10.00	3	0.10	10446	31	\N	\N
527	3.60	20	0.10	10446	24	\N	\N
528	7.30	12	0.10	10446	19	\N	\N
529	17.20	2	0.00	10447	71	\N	\N
530	16.80	35	0.00	10447	65	\N	\N
531	7.30	40	0.00	10447	19	\N	\N
532	14.70	20	0.00	10448	40	\N	\N
533	24.90	6	0.00	10448	26	\N	\N
534	39.40	35	0.00	10449	62	\N	\N
535	5.60	20	0.00	10449	52	\N	\N
536	24.80	14	0.00	10449	10	\N	\N
537	5.90	6	0.20	10450	54	\N	\N
538	24.80	20	0.20	10450	10	\N	\N
539	10.40	55	0.10	10451	77	\N	\N
540	16.80	28	0.10	10451	65	\N	\N
541	26.60	35	0.10	10451	64	\N	\N
542	19.20	120	0.10	10451	55	\N	\N
543	15.50	100	0.05	10452	44	\N	\N
544	36.40	15	0.00	10452	28	\N	\N
545	12.00	25	0.10	10453	70	\N	\N
546	10.20	15	0.10	10453	48	\N	\N
547	9.60	10	0.20	10454	46	\N	\N
548	2.00	20	0.20	10454	33	\N	\N
549	13.90	20	0.20	10454	16	\N	\N
550	17.20	30	0.00	10455	71	\N	\N
551	22.80	25	0.00	10455	61	\N	\N
552	26.20	50	0.00	10455	53	\N	\N
553	14.40	20	0.00	10455	39	\N	\N
554	16.00	21	0.15	10456	49	\N	\N
555	8.00	40	0.15	10456	21	\N	\N
556	44.00	36	0.00	10457	59	\N	\N
557	17.20	50	0.00	10458	71	\N	\N
558	30.40	15	0.00	10458	56	\N	\N
559	36.80	20	0.00	10458	43	\N	\N
560	36.40	30	0.00	10458	28	\N	\N
561	24.90	30	0.00	10458	26	\N	\N
562	27.80	40	0.00	10459	72	\N	\N
563	9.60	20	0.05	10459	46	\N	\N
564	24.00	16	0.05	10459	7	\N	\N
565	6.20	4	0.25	10460	75	\N	\N
566	10.00	21	0.25	10460	68	\N	\N
567	19.20	60	0.25	10461	55	\N	\N
568	20.70	28	0.25	10461	30	\N	\N
569	8.00	40	0.25	10461	21	\N	\N
570	7.20	21	0.00	10462	23	\N	\N
571	4.80	1	0.00	10462	13	\N	\N
572	11.20	50	0.00	10463	42	\N	\N
573	7.30	21	0.00	10463	19	\N	\N
574	27.20	20	0.00	10464	60	\N	\N
575	30.40	30	0.20	10464	56	\N	\N
576	36.80	3	0.00	10464	43	\N	\N
577	17.60	16	0.20	10464	4	\N	\N
578	13.00	25	0.00	10465	50	\N	\N
579	7.60	30	0.10	10465	45	\N	\N
580	14.70	20	0.00	10465	40	\N	\N
581	99.00	18	0.10	10465	29	\N	\N
582	3.60	25	0.00	10465	24	\N	\N
583	9.60	5	0.00	10466	46	\N	\N
584	16.80	10	0.00	10466	11	\N	\N
585	11.20	12	0.00	10467	25	\N	\N
586	3.60	28	0.00	10467	24	\N	\N
587	36.80	15	0.00	10468	43	\N	\N
588	20.70	8	0.00	10468	30	\N	\N
589	15.50	2	0.15	10469	44	\N	\N
590	13.90	35	0.15	10469	16	\N	\N
591	15.20	40	0.15	10469	2	\N	\N
592	26.60	8	0.00	10470	64	\N	\N
593	7.20	15	0.00	10470	23	\N	\N
594	50.00	30	0.00	10470	18	\N	\N
595	30.40	20	0.00	10471	56	\N	\N
596	24.00	30	0.00	10471	7	\N	\N
597	42.40	18	0.00	10472	51	\N	\N
598	3.60	80	0.05	10472	24	\N	\N
599	17.20	12	0.00	10473	71	\N	\N
600	2.00	12	0.00	10473	33	\N	\N
601	6.20	10	0.00	10474	75	\N	\N
602	14.70	21	0.00	10474	40	\N	\N
603	36.40	18	0.00	10474	28	\N	\N
604	18.60	12	0.00	10474	14	\N	\N
605	14.40	42	0.15	10475	76	\N	\N
606	13.60	60	0.15	10475	66	\N	\N
607	10.00	35	0.15	10475	31	\N	\N
608	12.00	12	0.00	10476	70	\N	\N
609	19.20	2	0.05	10476	55	\N	\N
610	14.40	20	0.25	10477	39	\N	\N
611	8.00	21	0.25	10477	21	\N	\N
612	14.40	15	0.00	10477	1	\N	\N
613	24.80	20	0.05	10478	10	\N	\N
614	26.60	30	0.00	10479	64	\N	\N
615	44.00	60	0.00	10479	59	\N	\N
616	26.20	28	0.00	10479	53	\N	\N
617	210.80	30	0.00	10479	38	\N	\N
618	44.00	12	0.00	10480	59	\N	\N
619	7.60	30	0.00	10480	47	\N	\N
620	27.20	40	0.00	10481	60	\N	\N
621	16.00	24	0.00	10481	49	\N	\N
622	14.70	10	0.00	10482	40	\N	\N
623	10.40	30	0.05	10483	77	\N	\N
624	11.20	35	0.05	10483	34	\N	\N
625	42.40	3	0.00	10484	51	\N	\N
626	14.70	10	0.00	10484	40	\N	\N
627	8.00	14	0.00	10484	21	\N	\N
628	12.00	60	0.10	10485	70	\N	\N
629	19.20	30	0.10	10485	55	\N	\N
630	8.00	20	0.10	10485	3	\N	\N
631	15.20	20	0.10	10485	2	\N	\N
632	8.00	16	0.00	10486	74	\N	\N
633	42.40	25	0.00	10486	51	\N	\N
634	16.80	5	0.00	10486	11	\N	\N
635	5.90	24	0.25	10487	54	\N	\N
636	24.90	30	0.00	10487	26	\N	\N
637	7.30	5	0.00	10487	19	\N	\N
638	12.00	20	0.20	10488	73	\N	\N
639	44.00	30	0.00	10488	59	\N	\N
640	13.90	18	0.00	10489	16	\N	\N
641	16.80	15	0.25	10489	11	\N	\N
642	6.20	36	0.00	10490	75	\N	\N
643	10.00	30	0.00	10490	68	\N	\N
644	44.00	60	0.00	10490	59	\N	\N
645	10.40	7	0.15	10491	77	\N	\N
646	15.50	15	0.15	10491	44	\N	\N
647	11.20	20	0.05	10492	42	\N	\N
648	11.20	60	0.05	10492	25	\N	\N
649	28.80	10	0.10	10493	69	\N	\N
650	13.60	10	0.10	10493	66	\N	\N
651	16.80	15	0.10	10493	65	\N	\N
652	30.40	30	0.00	10494	56	\N	\N
653	10.40	5	0.00	10495	77	\N	\N
654	7.70	20	0.00	10495	41	\N	\N
655	7.20	10	0.00	10495	23	\N	\N
656	10.00	20	0.05	10496	31	\N	\N
657	10.40	25	0.00	10497	77	\N	\N
658	27.80	25	0.00	10497	72	\N	\N
659	30.40	14	0.00	10497	56	\N	\N
660	14.00	30	0.00	10498	42	\N	\N
661	18.40	5	0.00	10498	40	\N	\N
662	4.50	14	0.00	10498	24	\N	\N
663	20.00	25	0.00	10499	49	\N	\N
664	45.60	20	0.00	10499	28	\N	\N
665	45.60	8	0.05	10500	28	\N	\N
666	15.50	12	0.05	10500	15	\N	\N
667	7.45	20	0.00	10501	54	\N	\N
668	14.00	30	0.00	10502	67	\N	\N
669	32.80	6	0.00	10502	53	\N	\N
670	9.50	21	0.00	10502	45	\N	\N
671	21.05	20	0.00	10503	65	\N	\N
672	23.25	70	0.00	10503	14	\N	\N
673	28.50	25	0.00	10504	61	\N	\N
674	32.80	10	0.00	10504	53	\N	\N
675	10.00	12	0.00	10504	21	\N	\N
676	19.00	12	0.00	10504	2	\N	\N
677	49.30	3	0.00	10505	62	\N	\N
678	15.00	14	0.10	10506	70	\N	\N
679	14.00	18	0.10	10506	25	\N	\N
680	12.75	15	0.15	10507	48	\N	\N
681	46.00	15	0.15	10507	43	\N	\N
682	18.00	10	0.00	10508	39	\N	\N
683	6.00	10	0.00	10508	13	\N	\N
684	45.60	3	0.00	10509	28	\N	\N
685	7.75	36	0.10	10510	75	\N	\N
686	123.79	36	0.00	10510	29	\N	\N
687	40.00	10	0.15	10511	8	\N	\N
688	30.00	50	0.15	10511	7	\N	\N
689	22.00	50	0.15	10511	4	\N	\N
690	34.00	12	0.15	10512	60	\N	\N
691	9.50	6	0.15	10512	47	\N	\N
692	12.00	9	0.15	10512	46	\N	\N
693	4.50	10	0.15	10512	24	\N	\N
694	28.50	15	0.20	10513	61	\N	\N
695	32.00	50	0.20	10513	32	\N	\N
696	10.00	40	0.20	10513	21	\N	\N
697	7.75	50	0.00	10514	75	\N	\N
698	21.05	39	0.00	10514	65	\N	\N
699	38.00	70	0.00	10514	56	\N	\N
700	45.60	35	0.00	10514	28	\N	\N
701	81.00	39	0.00	10514	20	\N	\N
702	34.00	84	0.15	10515	60	\N	\N
703	2.50	16	0.15	10515	33	\N	\N
704	43.90	120	0.00	10515	27	\N	\N
705	17.45	50	0.00	10515	16	\N	\N
706	97.00	16	0.15	10515	9	\N	\N
707	14.00	20	0.00	10516	42	\N	\N
708	9.65	80	0.10	10516	41	\N	\N
709	62.50	25	0.10	10516	18	\N	\N
710	15.00	6	0.00	10517	70	\N	\N
711	55.00	4	0.00	10517	59	\N	\N
712	7.00	6	0.00	10517	52	\N	\N
713	19.45	9	0.00	10518	44	\N	\N
714	263.50	15	0.00	10518	38	\N	\N
715	4.50	5	0.00	10518	24	\N	\N
716	34.00	10	0.05	10519	60	\N	\N
717	38.00	40	0.00	10519	56	\N	\N
718	31.00	16	0.05	10519	10	\N	\N
719	32.80	5	0.00	10520	53	\N	\N
720	4.50	8	0.00	10520	24	\N	\N
721	12.50	6	0.00	10521	68	\N	\N
722	9.65	10	0.00	10521	41	\N	\N
723	18.00	3	0.00	10521	35	\N	\N
724	18.40	25	0.20	10522	40	\N	\N
725	25.89	20	0.20	10522	30	\N	\N
726	40.00	24	0.00	10522	8	\N	\N
727	18.00	40	0.20	10522	1	\N	\N
728	9.65	6	0.10	10523	41	\N	\N
729	26.00	18	0.10	10523	37	\N	\N
730	81.00	15	0.10	10523	20	\N	\N
731	39.00	25	0.10	10523	17	\N	\N
732	7.45	15	0.00	10524	54	\N	\N
733	46.00	60	0.00	10524	43	\N	\N
734	25.89	10	0.00	10524	30	\N	\N
735	31.00	2	0.00	10524	10	\N	\N
736	18.40	15	0.10	10525	40	\N	\N
737	19.00	30	0.00	10525	36	\N	\N
738	38.00	30	0.15	10526	56	\N	\N
739	6.00	10	0.00	10526	13	\N	\N
740	18.00	8	0.15	10526	1	\N	\N
741	19.00	30	0.10	10527	36	\N	\N
742	22.00	50	0.10	10527	4	\N	\N
743	34.80	9	0.00	10528	72	\N	\N
744	2.50	8	0.20	10528	33	\N	\N
745	21.00	3	0.00	10528	11	\N	\N
746	36.00	10	0.00	10529	69	\N	\N
747	12.50	20	0.00	10529	68	\N	\N
748	24.00	14	0.00	10529	55	\N	\N
749	18.00	50	0.00	10530	76	\N	\N
750	28.50	20	0.00	10530	61	\N	\N
751	46.00	25	0.00	10530	43	\N	\N
752	39.00	40	0.00	10530	17	\N	\N
753	55.00	2	0.00	10531	59	\N	\N
754	17.00	24	0.00	10532	66	\N	\N
755	25.89	15	0.00	10532	30	\N	\N
756	15.00	24	0.05	10533	73	\N	\N
757	34.80	24	0.00	10533	72	\N	\N
758	22.00	50	0.05	10533	4	\N	\N
759	7.45	10	0.20	10534	54	\N	\N
760	18.40	10	0.20	10534	40	\N	\N
761	25.89	10	0.00	10534	30	\N	\N
762	55.00	15	0.10	10535	59	\N	\N
763	19.50	5	0.10	10535	57	\N	\N
764	18.40	10	0.10	10535	40	\N	\N
765	21.00	50	0.10	10535	11	\N	\N
766	34.00	35	0.25	10536	60	\N	\N
767	2.50	30	0.00	10536	33	\N	\N
768	12.50	20	0.00	10536	31	\N	\N
769	38.00	15	0.25	10536	12	\N	\N
770	15.00	9	0.00	10537	73	\N	\N
771	34.80	21	0.00	10537	72	\N	\N
772	13.25	20	0.00	10537	58	\N	\N
773	53.00	6	0.00	10537	51	\N	\N
774	12.50	30	0.00	10537	31	\N	\N
775	34.80	1	0.00	10538	72	\N	\N
776	15.00	7	0.00	10538	70	\N	\N
777	20.00	6	0.00	10539	49	\N	\N
778	2.50	15	0.00	10539	33	\N	\N
779	10.00	15	0.00	10539	21	\N	\N
780	6.00	8	0.00	10539	13	\N	\N
781	12.50	35	0.00	10540	68	\N	\N
782	263.50	30	0.00	10540	38	\N	\N
783	31.23	40	0.00	10540	26	\N	\N
784	10.00	60	0.00	10540	3	\N	\N
785	21.50	9	0.10	10541	71	\N	\N
786	21.05	36	0.10	10541	65	\N	\N
787	263.50	4	0.10	10541	38	\N	\N
788	4.50	35	0.10	10541	24	\N	\N
789	7.45	24	0.05	10542	54	\N	\N
790	21.00	15	0.05	10542	11	\N	\N
791	9.00	70	0.15	10543	23	\N	\N
792	38.00	30	0.15	10543	12	\N	\N
793	14.00	7	0.00	10544	67	\N	\N
794	45.60	7	0.00	10544	28	\N	\N
795	21.00	10	0.00	10545	11	\N	\N
796	49.30	40	0.00	10546	62	\N	\N
797	18.00	30	0.00	10546	35	\N	\N
798	30.00	10	0.00	10546	7	\N	\N
799	19.00	60	0.00	10547	36	\N	\N
800	32.00	24	0.15	10547	32	\N	\N
801	9.65	14	0.00	10548	41	\N	\N
802	14.00	10	0.25	10548	34	\N	\N
803	53.00	48	0.15	10549	51	\N	\N
804	9.50	100	0.15	10549	45	\N	\N
805	12.50	55	0.15	10549	31	\N	\N
806	28.50	10	0.10	10550	61	\N	\N
807	10.00	6	0.10	10550	21	\N	\N
808	9.20	10	0.00	10550	19	\N	\N
809	39.00	8	0.10	10550	17	\N	\N
810	19.45	40	0.00	10551	44	\N	\N
811	18.00	20	0.15	10551	35	\N	\N
812	17.45	40	0.15	10551	16	\N	\N
813	7.75	30	0.00	10552	75	\N	\N
814	36.00	18	0.00	10552	69	\N	\N
815	18.00	6	0.00	10553	35	\N	\N
816	12.50	30	0.00	10553	31	\N	\N
817	21.00	24	0.00	10553	22	\N	\N
818	17.45	14	0.00	10553	16	\N	\N
819	21.00	15	0.00	10553	11	\N	\N
820	13.00	10	0.05	10554	77	\N	\N
821	49.30	20	0.05	10554	62	\N	\N
822	9.00	20	0.05	10554	23	\N	\N
823	17.45	30	0.05	10554	16	\N	\N
824	38.00	40	0.20	10555	56	\N	\N
825	53.00	20	0.20	10555	51	\N	\N
826	4.50	18	0.20	10555	24	\N	\N
827	9.20	35	0.20	10555	19	\N	\N
828	23.25	30	0.20	10555	14	\N	\N
829	34.80	24	0.00	10556	72	\N	\N
830	7.75	20	0.00	10557	75	\N	\N
831	33.25	30	0.00	10557	64	\N	\N
832	15.00	3	0.00	10558	73	\N	\N
833	32.80	18	0.00	10558	53	\N	\N
834	7.00	30	0.00	10558	52	\N	\N
835	53.00	20	0.00	10558	51	\N	\N
836	9.50	25	0.00	10558	47	\N	\N
837	24.00	18	0.05	10559	55	\N	\N
838	9.65	12	0.05	10559	41	\N	\N
839	49.30	15	0.25	10560	62	\N	\N
840	25.89	20	0.00	10560	30	\N	\N
841	53.00	50	0.00	10561	51	\N	\N
842	19.45	10	0.00	10561	44	\N	\N
843	49.30	10	0.10	10562	62	\N	\N
844	2.50	20	0.10	10562	33	\N	\N
845	7.00	70	0.00	10563	52	\N	\N
846	19.00	25	0.00	10563	36	\N	\N
847	24.00	25	0.05	10564	55	\N	\N
848	12.50	6	0.05	10564	31	\N	\N
849	39.00	16	0.05	10564	17	\N	\N
850	33.25	18	0.10	10565	64	\N	\N
851	4.50	25	0.10	10565	24	\N	\N
852	18.00	10	0.00	10566	76	\N	\N
853	62.50	18	0.15	10566	18	\N	\N
854	21.00	35	0.15	10566	11	\N	\N
855	55.00	40	0.20	10567	59	\N	\N
856	53.00	3	0.00	10567	51	\N	\N
857	12.50	60	0.20	10567	31	\N	\N
858	31.00	5	0.00	10568	10	\N	\N
859	18.00	30	0.00	10569	76	\N	\N
860	12.50	35	0.20	10569	31	\N	\N
861	38.00	60	0.05	10570	56	\N	\N
862	21.00	15	0.05	10570	11	\N	\N
863	14.00	28	0.15	10571	42	\N	\N
864	23.25	11	0.15	10571	14	\N	\N
865	7.75	15	0.10	10572	75	\N	\N
866	18.40	50	0.00	10572	40	\N	\N
867	32.00	10	0.10	10572	32	\N	\N
868	17.45	12	0.10	10572	16	\N	\N
869	32.80	25	0.00	10573	53	\N	\N
870	14.00	40	0.00	10573	34	\N	\N
871	39.00	18	0.00	10573	17	\N	\N
872	33.25	6	0.00	10574	64	\N	\N
873	49.30	10	0.00	10574	62	\N	\N
874	18.40	2	0.00	10574	40	\N	\N
875	2.50	14	0.00	10574	33	\N	\N
876	18.00	10	0.00	10575	76	\N	\N
877	34.80	30	0.00	10575	72	\N	\N
878	43.90	6	0.00	10575	63	\N	\N
879	55.00	12	0.00	10575	59	\N	\N
880	19.45	21	0.00	10576	44	\N	\N
881	12.50	20	0.00	10576	31	\N	\N
882	18.00	10	0.00	10576	1	\N	\N
883	13.00	18	0.00	10577	77	\N	\N
884	7.75	20	0.00	10577	75	\N	\N
885	18.00	10	0.00	10577	39	\N	\N
886	19.50	6	0.00	10578	57	\N	\N
887	18.00	20	0.00	10578	35	\N	\N
888	7.75	21	0.00	10579	75	\N	\N
889	15.50	10	0.00	10579	15	\N	\N
890	21.05	30	0.05	10580	65	\N	\N
891	9.65	9	0.05	10580	41	\N	\N
892	23.25	15	0.05	10580	14	\N	\N
893	7.75	50	0.20	10581	75	\N	\N
894	18.00	14	0.00	10582	76	\N	\N
895	19.50	4	0.00	10582	57	\N	\N
896	36.00	10	0.15	10583	69	\N	\N
897	34.00	24	0.15	10583	60	\N	\N
898	123.79	10	0.00	10583	29	\N	\N
899	12.50	50	0.05	10584	31	\N	\N
900	9.50	15	0.00	10585	47	\N	\N
901	7.00	4	0.15	10586	52	\N	\N
902	13.00	20	0.00	10587	77	\N	\N
903	18.00	20	0.00	10587	35	\N	\N
904	31.23	6	0.00	10587	26	\N	\N
905	14.00	100	0.20	10588	42	\N	\N
906	62.50	40	0.20	10588	18	\N	\N
907	18.00	4	0.00	10589	35	\N	\N
908	13.00	60	0.05	10590	77	\N	\N
909	18.00	20	0.00	10590	1	\N	\N
910	7.45	50	0.00	10591	54	\N	\N
911	30.00	10	0.00	10591	7	\N	\N
912	10.00	14	0.00	10591	3	\N	\N
913	31.23	5	0.05	10592	26	\N	\N
914	15.50	25	0.05	10592	15	\N	\N
915	18.00	4	0.20	10593	76	\N	\N
916	36.00	20	0.20	10593	69	\N	\N
917	81.00	21	0.20	10593	20	\N	\N
918	13.25	30	0.00	10594	58	\N	\N
919	7.00	24	0.00	10594	52	\N	\N
920	36.00	65	0.25	10595	69	\N	\N
921	28.50	120	0.25	10595	61	\N	\N
922	18.00	30	0.25	10595	35	\N	\N
923	7.75	30	0.20	10596	75	\N	\N
924	43.90	24	0.20	10596	63	\N	\N
925	38.00	5	0.20	10596	56	\N	\N
926	21.05	12	0.20	10597	65	\N	\N
927	19.50	20	0.00	10597	57	\N	\N
928	4.50	35	0.20	10597	24	\N	\N
929	21.50	9	0.00	10598	71	\N	\N
930	43.90	50	0.00	10598	27	\N	\N
931	49.30	10	0.00	10599	62	\N	\N
932	15.00	30	0.00	10600	73	\N	\N
933	7.45	4	0.00	10600	54	\N	\N
934	55.00	35	0.00	10601	59	\N	\N
935	6.00	60	0.00	10601	13	\N	\N
936	13.00	5	0.25	10602	77	\N	\N
937	20.00	25	0.05	10603	49	\N	\N
938	21.00	48	0.00	10603	22	\N	\N
939	18.00	10	0.10	10604	76	\N	\N
940	12.75	6	0.10	10604	48	\N	\N
941	21.50	15	0.05	10605	71	\N	\N
942	34.00	70	0.05	10605	60	\N	\N
943	55.00	20	0.05	10605	59	\N	\N
944	17.45	30	0.05	10605	16	\N	\N
945	49.30	10	0.20	10606	62	\N	\N
946	24.00	20	0.20	10606	55	\N	\N
947	22.00	20	0.20	10606	4	\N	\N
948	34.80	12	0.00	10607	72	\N	\N
949	18.40	42	0.00	10607	40	\N	\N
950	2.50	14	0.00	10607	33	\N	\N
951	39.00	100	0.00	10607	17	\N	\N
952	30.00	45	0.00	10607	7	\N	\N
953	38.00	28	0.00	10608	56	\N	\N
954	10.00	6	0.00	10609	21	\N	\N
955	31.00	10	0.00	10609	10	\N	\N
956	18.00	3	0.00	10609	1	\N	\N
957	19.00	21	0.25	10610	36	\N	\N
958	34.00	15	0.00	10611	60	\N	\N
959	19.00	10	0.00	10611	2	\N	\N
960	18.00	6	0.00	10611	1	\N	\N
961	18.00	80	0.00	10612	76	\N	\N
962	34.00	40	0.00	10612	60	\N	\N
963	20.00	18	0.00	10612	49	\N	\N
964	19.00	55	0.00	10612	36	\N	\N
965	31.00	70	0.00	10612	10	\N	\N
966	7.75	40	0.00	10613	75	\N	\N
967	6.00	8	0.10	10613	13	\N	\N
968	18.00	5	0.00	10614	39	\N	\N
969	10.00	8	0.00	10614	21	\N	\N
970	21.00	14	0.00	10614	11	\N	\N
971	24.00	5	0.00	10615	55	\N	\N
972	21.50	15	0.05	10616	71	\N	\N
973	15.00	15	0.05	10616	70	\N	\N
974	38.00	14	0.00	10616	56	\N	\N
975	263.50	15	0.05	10616	38	\N	\N
976	55.00	30	0.15	10617	59	\N	\N
977	12.50	15	0.00	10618	68	\N	\N
978	38.00	20	0.00	10618	56	\N	\N
979	25.00	70	0.00	10618	6	\N	\N
980	21.00	40	0.00	10619	22	\N	\N
981	10.00	42	0.00	10619	21	\N	\N
982	7.00	5	0.00	10620	52	\N	\N
983	4.50	5	0.00	10620	24	\N	\N
984	21.50	15	0.00	10621	71	\N	\N
985	15.00	20	0.00	10621	70	\N	\N
986	9.00	10	0.00	10621	23	\N	\N
987	9.20	5	0.00	10621	19	\N	\N
988	12.50	18	0.20	10622	68	\N	\N
989	19.00	20	0.00	10622	2	\N	\N
990	18.00	30	0.10	10623	35	\N	\N
991	4.50	3	0.00	10623	24	\N	\N
992	10.00	25	0.10	10623	21	\N	\N
993	9.20	15	0.10	10623	19	\N	\N
994	23.25	21	0.00	10623	14	\N	\N
995	19.45	10	0.00	10624	44	\N	\N
996	123.79	6	0.00	10624	29	\N	\N
997	45.60	10	0.00	10624	28	\N	\N
998	34.00	10	0.00	10625	60	\N	\N
999	14.00	5	0.00	10625	42	\N	\N
1000	23.25	3	0.00	10625	14	\N	\N
1001	21.50	20	0.00	10626	71	\N	\N
1002	34.00	20	0.00	10626	60	\N	\N
1003	32.80	12	0.00	10626	53	\N	\N
1004	15.00	35	0.15	10627	73	\N	\N
1005	49.30	15	0.00	10627	62	\N	\N
1006	18.00	25	0.00	10628	1	\N	\N
1007	33.25	9	0.00	10629	64	\N	\N
1008	123.79	20	0.00	10629	29	\N	\N
1009	18.00	35	0.00	10630	76	\N	\N
1010	24.00	12	0.05	10630	55	\N	\N
1011	7.75	8	0.10	10631	75	\N	\N
1012	2.50	20	0.05	10632	33	\N	\N
1013	19.00	30	0.05	10632	2	\N	\N
1014	49.30	80	0.15	10633	62	\N	\N
1015	31.23	35	0.15	10633	26	\N	\N
1016	6.00	13	0.15	10633	13	\N	\N
1017	38.00	36	0.15	10633	12	\N	\N
1018	7.75	2	0.00	10634	75	\N	\N
1019	53.00	15	0.00	10634	51	\N	\N
1020	62.50	50	0.00	10634	18	\N	\N
1021	30.00	35	0.00	10634	7	\N	\N
1022	21.00	40	0.00	10635	22	\N	\N
1023	21.35	15	0.10	10635	5	\N	\N
1024	22.00	10	0.10	10635	4	\N	\N
1025	13.25	6	0.00	10636	58	\N	\N
1026	22.00	25	0.00	10636	4	\N	\N
1027	38.00	60	0.05	10637	56	\N	\N
1028	16.25	25	0.05	10637	50	\N	\N
1029	21.00	10	0.00	10637	11	\N	\N
1030	34.80	60	0.00	10638	72	\N	\N
1031	21.05	21	0.00	10638	65	\N	\N
1032	9.50	20	0.00	10638	45	\N	\N
1033	62.50	8	0.00	10639	18	\N	\N
1034	15.00	15	0.25	10640	70	\N	\N
1035	36.00	20	0.25	10640	69	\N	\N
1036	18.40	60	0.00	10641	40	\N	\N
1037	19.00	50	0.00	10641	2	\N	\N
1038	28.50	20	0.20	10642	61	\N	\N
1039	10.00	30	0.20	10642	21	\N	\N
1040	12.00	2	0.25	10643	46	\N	\N
1041	18.00	21	0.25	10643	39	\N	\N
1042	45.60	15	0.25	10643	28	\N	\N
1043	12.00	21	0.10	10644	46	\N	\N
1044	46.00	20	0.00	10644	43	\N	\N
1045	62.50	4	0.10	10644	18	\N	\N
1046	19.00	15	0.00	10645	36	\N	\N
1047	62.50	20	0.00	10645	18	\N	\N
1048	13.00	35	0.25	10646	77	\N	\N
1049	21.50	30	0.25	10646	71	\N	\N
1050	31.00	18	0.25	10646	10	\N	\N
1051	18.00	15	0.25	10646	1	\N	\N
1052	18.00	20	0.00	10647	39	\N	\N
1053	9.20	30	0.00	10647	19	\N	\N
1054	4.50	15	0.15	10648	24	\N	\N
1055	21.00	15	0.00	10648	22	\N	\N
1056	34.80	15	0.00	10649	72	\N	\N
1057	45.60	20	0.00	10649	28	\N	\N
1058	7.45	30	0.00	10650	54	\N	\N
1059	32.80	25	0.05	10650	53	\N	\N
1060	25.89	30	0.00	10650	30	\N	\N
1061	21.00	20	0.25	10651	22	\N	\N
1062	9.20	12	0.25	10651	19	\N	\N
1063	14.00	20	0.00	10652	42	\N	\N
1064	25.89	2	0.25	10652	30	\N	\N
1065	34.00	20	0.10	10653	60	\N	\N
1066	17.45	30	0.10	10653	16	\N	\N
1067	7.45	6	0.10	10654	54	\N	\N
1068	18.00	20	0.10	10654	39	\N	\N
1069	22.00	12	0.10	10654	4	\N	\N
1070	9.65	20	0.20	10655	41	\N	\N
1071	9.50	6	0.10	10656	47	\N	\N
1072	19.45	28	0.10	10656	44	\N	\N
1073	23.25	3	0.10	10656	14	\N	\N
1074	34.00	30	0.00	10657	60	\N	\N
1075	38.00	45	0.00	10657	56	\N	\N
1076	9.50	10	0.00	10657	47	\N	\N
1077	12.00	45	0.00	10657	46	\N	\N
1078	9.65	24	0.00	10657	41	\N	\N
1079	15.50	50	0.00	10657	15	\N	\N
1080	13.00	70	0.05	10658	77	\N	\N
1081	34.00	55	0.05	10658	60	\N	\N
1082	18.40	70	0.05	10658	40	\N	\N
1083	10.00	60	0.00	10658	21	\N	\N
1084	15.00	40	0.05	10659	70	\N	\N
1085	18.40	24	0.05	10659	40	\N	\N
1086	12.50	20	0.05	10659	31	\N	\N
1087	81.00	21	0.00	10660	20	\N	\N
1088	13.25	49	0.20	10661	58	\N	\N
1089	18.00	3	0.20	10661	39	\N	\N
1090	12.50	10	0.00	10662	68	\N	\N
1091	53.00	20	0.05	10663	51	\N	\N
1092	14.00	30	0.05	10663	42	\N	\N
1093	18.40	30	0.05	10663	40	\N	\N
1094	21.05	15	0.15	10664	65	\N	\N
1095	38.00	12	0.15	10664	56	\N	\N
1096	31.00	24	0.15	10664	10	\N	\N
1097	18.00	10	0.00	10665	76	\N	\N
1098	55.00	1	0.00	10665	59	\N	\N
1099	53.00	20	0.00	10665	51	\N	\N
1100	21.05	10	0.00	10666	65	\N	\N
1101	123.79	36	0.00	10666	29	\N	\N
1102	21.50	14	0.20	10667	71	\N	\N
1103	36.00	45	0.20	10667	69	\N	\N
1104	33.25	15	0.10	10668	64	\N	\N
1105	24.00	4	0.10	10668	55	\N	\N
1106	12.50	8	0.10	10668	31	\N	\N
1107	19.00	30	0.00	10669	36	\N	\N
1108	7.75	25	0.00	10670	75	\N	\N
1109	15.00	50	0.00	10670	73	\N	\N
1110	14.00	25	0.00	10670	67	\N	\N
1111	12.00	60	0.00	10670	46	\N	\N
1112	9.00	32	0.00	10670	23	\N	\N
1113	21.05	12	0.00	10671	65	\N	\N
1114	49.30	10	0.00	10671	62	\N	\N
1115	17.45	10	0.00	10671	16	\N	\N
1116	21.50	12	0.00	10672	71	\N	\N
1117	263.50	15	0.10	10672	38	\N	\N
1118	46.00	6	0.00	10673	43	\N	\N
1119	14.00	6	0.00	10673	42	\N	\N
1120	17.45	3	0.00	10673	16	\N	\N
1121	9.00	5	0.00	10674	23	\N	\N
1122	13.25	30	0.00	10675	58	\N	\N
1123	32.80	10	0.00	10675	53	\N	\N
1124	23.25	30	0.00	10675	14	\N	\N
1125	19.45	21	0.00	10676	44	\N	\N
1126	9.20	7	0.00	10676	19	\N	\N
1127	31.00	2	0.00	10676	10	\N	\N
1128	2.50	8	0.15	10677	33	\N	\N
1129	31.23	30	0.15	10677	26	\N	\N
1130	7.45	30	0.00	10678	54	\N	\N
1131	9.65	120	0.00	10678	41	\N	\N
1132	2.50	30	0.00	10678	33	\N	\N
1133	38.00	100	0.00	10678	12	\N	\N
1134	55.00	12	0.00	10679	59	\N	\N
1135	14.00	40	0.25	10680	42	\N	\N
1136	12.50	20	0.25	10680	31	\N	\N
1137	17.45	50	0.25	10680	16	\N	\N
1138	33.25	28	0.00	10681	64	\N	\N
1139	10.00	12	0.10	10681	21	\N	\N
1140	9.20	30	0.10	10681	19	\N	\N
1141	7.75	30	0.00	10682	75	\N	\N
1142	17.00	4	0.00	10682	66	\N	\N
1143	2.50	30	0.00	10682	33	\N	\N
1144	7.00	9	0.00	10683	52	\N	\N
1145	34.00	30	0.00	10684	60	\N	\N
1146	9.50	40	0.00	10684	47	\N	\N
1147	18.40	20	0.00	10684	40	\N	\N
1148	9.50	15	0.00	10685	47	\N	\N
1149	9.65	4	0.00	10685	41	\N	\N
1150	31.00	20	0.00	10685	10	\N	\N
1151	31.23	15	0.00	10686	26	\N	\N
1152	39.00	30	0.20	10686	17	\N	\N
1153	19.00	6	0.25	10687	36	\N	\N
1154	123.79	10	0.00	10687	29	\N	\N
1155	97.00	50	0.25	10687	9	\N	\N
1156	14.00	14	0.00	10688	34	\N	\N
1157	45.60	60	0.10	10688	28	\N	\N
1158	31.00	18	0.10	10688	10	\N	\N
1159	18.00	35	0.25	10689	1	\N	\N
1160	13.00	30	0.25	10690	77	\N	\N
1161	38.00	20	0.25	10690	56	\N	\N
1162	49.30	48	0.00	10691	62	\N	\N
1163	19.45	24	0.00	10691	44	\N	\N
1164	46.00	40	0.00	10691	43	\N	\N
1165	123.79	40	0.00	10691	29	\N	\N
1166	18.00	30	0.00	10691	1	\N	\N
1167	43.90	20	0.00	10692	63	\N	\N
1168	15.00	15	0.15	10693	73	\N	\N
1169	36.00	30	0.15	10693	69	\N	\N
1170	7.45	60	0.15	10693	54	\N	\N
1171	97.00	6	0.00	10693	9	\N	\N
1172	15.00	50	0.00	10694	70	\N	\N
1173	55.00	25	0.00	10694	59	\N	\N
1174	30.00	90	0.00	10694	7	\N	\N
1175	4.50	20	0.00	10695	24	\N	\N
1176	38.00	4	0.00	10695	12	\N	\N
1177	40.00	10	0.00	10695	8	\N	\N
1178	12.00	18	0.00	10696	46	\N	\N
1179	39.00	20	0.00	10696	17	\N	\N
1180	15.00	30	0.25	10697	70	\N	\N
1181	13.25	30	0.25	10697	58	\N	\N
1182	18.00	9	0.25	10697	35	\N	\N
1183	9.20	7	0.25	10697	19	\N	\N
1184	15.00	8	0.05	10698	70	\N	\N
1185	21.05	65	0.05	10698	65	\N	\N
1186	123.79	12	0.05	10698	29	\N	\N
1187	39.00	8	0.05	10698	17	\N	\N
1188	21.00	15	0.00	10698	11	\N	\N
1189	9.50	12	0.00	10699	47	\N	\N
1190	21.50	60	0.20	10700	71	\N	\N
1191	12.50	40	0.20	10700	68	\N	\N
1192	14.00	12	0.20	10700	34	\N	\N
1193	18.00	5	0.20	10700	1	\N	\N
1194	18.00	35	0.15	10701	76	\N	\N
1195	21.50	20	0.15	10701	71	\N	\N
1196	55.00	42	0.15	10701	59	\N	\N
1197	18.00	15	0.00	10702	76	\N	\N
1198	10.00	6	0.00	10702	3	\N	\N
1199	15.00	35	0.00	10703	73	\N	\N
1200	55.00	35	0.00	10703	59	\N	\N
1201	19.00	5	0.00	10703	2	\N	\N
1202	12.75	24	0.00	10704	48	\N	\N
1203	4.50	35	0.00	10704	24	\N	\N
1204	22.00	6	0.00	10704	4	\N	\N
1205	32.00	4	0.00	10705	32	\N	\N
1206	12.50	20	0.00	10705	31	\N	\N
1207	55.00	8	0.00	10706	59	\N	\N
1208	46.00	24	0.00	10706	43	\N	\N
1209	17.45	20	0.00	10706	16	\N	\N
1210	15.00	28	0.15	10707	70	\N	\N
1211	19.50	40	0.00	10707	57	\N	\N
1212	24.00	21	0.00	10707	55	\N	\N
1213	19.00	5	0.00	10708	36	\N	\N
1214	21.35	4	0.00	10708	5	\N	\N
1215	34.00	10	0.00	10709	60	\N	\N
1216	53.00	28	0.00	10709	51	\N	\N
1217	40.00	40	0.00	10709	8	\N	\N
1218	9.50	5	0.00	10710	47	\N	\N
1219	9.20	5	0.00	10710	19	\N	\N
1220	32.80	120	0.00	10711	53	\N	\N
1221	9.65	42	0.00	10711	41	\N	\N
1222	9.20	12	0.00	10711	19	\N	\N
1223	38.00	30	0.00	10712	56	\N	\N
1224	32.80	3	0.05	10712	53	\N	\N
1225	12.00	24	0.00	10713	46	\N	\N
1226	9.50	110	0.00	10713	45	\N	\N
1227	31.23	30	0.00	10713	26	\N	\N
1228	31.00	18	0.00	10713	10	\N	\N
1229	13.25	12	0.25	10714	58	\N	\N
1230	38.00	18	0.25	10714	56	\N	\N
1231	9.50	50	0.25	10714	47	\N	\N
1232	39.00	27	0.25	10714	17	\N	\N
1233	19.00	30	0.25	10714	2	\N	\N
1234	21.50	30	0.00	10715	71	\N	\N
1235	31.00	21	0.00	10715	10	\N	\N
1236	28.50	10	0.00	10716	61	\N	\N
1237	53.00	7	0.00	10716	51	\N	\N
1238	10.00	5	0.00	10716	21	\N	\N
1239	36.00	25	0.05	10717	69	\N	\N
1240	7.45	15	0.00	10717	54	\N	\N
1241	10.00	32	0.05	10717	21	\N	\N
1242	49.30	20	0.00	10718	62	\N	\N
1243	19.00	40	0.00	10718	36	\N	\N
1244	17.45	20	0.00	10718	16	\N	\N
1245	38.00	36	0.00	10718	12	\N	\N
1246	7.45	40	0.25	10719	54	\N	\N
1247	25.89	3	0.25	10719	30	\N	\N
1248	62.50	12	0.25	10719	18	\N	\N
1249	21.50	8	0.00	10720	71	\N	\N
1250	18.00	21	0.00	10720	35	\N	\N
1251	19.45	50	0.05	10721	44	\N	\N
1252	7.75	42	0.00	10722	75	\N	\N
1253	12.50	45	0.00	10722	68	\N	\N
1254	12.50	50	0.00	10722	31	\N	\N
1255	19.00	3	0.00	10722	2	\N	\N
1256	31.23	15	0.00	10723	26	\N	\N
1257	28.50	5	0.00	10724	61	\N	\N
1258	31.00	16	0.00	10724	10	\N	\N
1259	24.00	6	0.00	10725	55	\N	\N
1260	7.00	4	0.00	10725	52	\N	\N
1261	9.65	12	0.00	10725	41	\N	\N
1262	21.00	5	0.00	10726	11	\N	\N
1263	22.00	25	0.00	10726	4	\N	\N
1264	55.00	10	0.05	10727	59	\N	\N
1265	38.00	10	0.05	10727	56	\N	\N
1266	39.00	20	0.05	10727	17	\N	\N
1267	34.00	15	0.00	10728	60	\N	\N
1268	24.00	12	0.00	10728	55	\N	\N
1269	18.40	6	0.00	10728	40	\N	\N
1270	25.89	15	0.00	10728	30	\N	\N
1271	16.25	40	0.00	10729	50	\N	\N
1272	10.00	30	0.00	10729	21	\N	\N
1273	18.00	50	0.00	10729	1	\N	\N
1274	21.05	10	0.05	10730	65	\N	\N
1275	12.50	3	0.05	10730	31	\N	\N
1276	17.45	15	0.05	10730	16	\N	\N
1277	53.00	30	0.05	10731	51	\N	\N
1278	10.00	40	0.05	10731	21	\N	\N
1279	18.00	20	0.00	10732	76	\N	\N
1280	7.00	25	0.00	10733	52	\N	\N
1281	45.60	20	0.00	10733	28	\N	\N
1282	23.25	16	0.00	10733	14	\N	\N
1283	18.00	20	0.00	10734	76	\N	\N
1284	25.89	15	0.00	10734	30	\N	\N
1285	25.00	30	0.00	10734	6	\N	\N
1286	13.00	2	0.10	10735	77	\N	\N
1287	28.50	20	0.10	10735	61	\N	\N
1288	7.75	20	0.00	10736	75	\N	\N
1289	21.05	40	0.00	10736	65	\N	\N
1290	9.65	12	0.00	10737	41	\N	\N
1291	6.00	4	0.00	10737	13	\N	\N
1292	17.45	3	0.00	10738	16	\N	\N
1293	7.00	18	0.00	10739	52	\N	\N
1294	19.00	6	0.00	10739	36	\N	\N
1295	38.00	14	0.20	10740	56	\N	\N
1296	9.50	40	0.20	10740	45	\N	\N
1297	18.00	35	0.20	10740	35	\N	\N
1298	45.60	5	0.20	10740	28	\N	\N
1299	19.00	15	0.20	10741	2	\N	\N
1300	34.80	35	0.00	10742	72	\N	\N
1301	34.00	50	0.00	10742	60	\N	\N
1302	10.00	20	0.00	10742	3	\N	\N
1303	12.00	28	0.05	10743	46	\N	\N
1304	18.40	50	0.20	10744	40	\N	\N
1305	34.80	7	0.00	10745	72	\N	\N
1306	55.00	45	0.00	10745	59	\N	\N
1307	19.45	16	0.00	10745	44	\N	\N
1308	62.50	24	0.00	10745	18	\N	\N
1309	36.00	40	0.00	10746	69	\N	\N
1310	49.30	9	0.00	10746	62	\N	\N
1311	14.00	28	0.00	10746	42	\N	\N
1312	6.00	6	0.00	10746	13	\N	\N
1313	36.00	30	0.00	10747	69	\N	\N
1314	43.90	9	0.00	10747	63	\N	\N
1315	9.65	35	0.00	10747	41	\N	\N
1316	12.50	8	0.00	10747	31	\N	\N
1317	38.00	28	0.00	10748	56	\N	\N
1318	18.40	40	0.00	10748	40	\N	\N
1319	9.00	44	0.00	10748	23	\N	\N
1320	18.00	10	0.00	10749	76	\N	\N
1321	55.00	6	0.00	10749	59	\N	\N
1322	38.00	15	0.00	10749	56	\N	\N
1323	55.00	25	0.15	10750	59	\N	\N
1324	9.50	40	0.15	10750	45	\N	\N
1325	23.25	5	0.15	10750	14	\N	\N
1326	15.00	15	0.00	10751	73	\N	\N
1327	16.25	20	0.10	10751	50	\N	\N
1328	25.89	30	0.00	10751	30	\N	\N
1329	31.23	12	0.10	10751	26	\N	\N
1330	36.00	3	0.00	10752	69	\N	\N
1331	18.00	8	0.00	10752	1	\N	\N
1332	10.00	5	0.00	10753	74	\N	\N
1333	9.50	4	0.00	10753	45	\N	\N
1334	18.40	3	0.00	10754	40	\N	\N
1335	36.00	25	0.25	10755	69	\N	\N
1336	19.50	14	0.25	10755	57	\N	\N
1337	38.00	30	0.25	10755	56	\N	\N
1338	9.50	30	0.25	10755	47	\N	\N
1339	36.00	20	0.20	10756	69	\N	\N
1340	12.50	6	0.20	10756	68	\N	\N
1341	19.00	20	0.20	10756	36	\N	\N
1342	62.50	21	0.20	10756	18	\N	\N
1343	33.25	24	0.00	10757	64	\N	\N
1344	49.30	30	0.00	10757	62	\N	\N
1345	55.00	7	0.00	10757	59	\N	\N
1346	14.00	30	0.00	10757	34	\N	\N
1347	15.00	40	0.00	10758	70	\N	\N
1348	7.00	60	0.00	10758	52	\N	\N
1349	31.23	20	0.00	10758	26	\N	\N
1350	32.00	10	0.00	10759	32	\N	\N
1351	46.00	30	0.25	10760	43	\N	\N
1352	43.90	40	0.00	10760	27	\N	\N
1353	14.00	12	0.25	10760	25	\N	\N
1354	7.75	18	0.00	10761	75	\N	\N
1355	14.00	35	0.25	10761	25	\N	\N
1356	38.00	60	0.00	10762	56	\N	\N
1357	53.00	28	0.00	10762	51	\N	\N
1358	9.50	30	0.00	10762	47	\N	\N
1359	18.00	16	0.00	10762	39	\N	\N
1360	4.50	20	0.00	10763	24	\N	\N
1361	21.00	6	0.00	10763	22	\N	\N
1362	10.00	40	0.00	10763	21	\N	\N
1363	18.00	130	0.10	10764	39	\N	\N
1364	10.00	20	0.10	10764	3	\N	\N
1365	21.05	80	0.10	10765	65	\N	\N
1366	12.50	40	0.00	10766	68	\N	\N
1367	30.00	35	0.00	10766	7	\N	\N
1368	19.00	40	0.00	10766	2	\N	\N
1369	14.00	2	0.00	10767	42	\N	\N
1370	21.50	12	0.00	10768	71	\N	\N
1371	34.00	15	0.00	10768	60	\N	\N
1372	12.50	50	0.00	10768	31	\N	\N
1373	21.00	4	0.00	10768	22	\N	\N
1374	49.30	15	0.00	10769	62	\N	\N
1375	28.50	20	0.00	10769	61	\N	\N
1376	7.00	15	0.05	10769	52	\N	\N
1377	9.65	30	0.05	10769	41	\N	\N
1378	21.00	15	0.25	10770	11	\N	\N
1379	21.50	16	0.00	10771	71	\N	\N
1380	55.00	25	0.00	10772	59	\N	\N
1381	123.79	18	0.00	10772	29	\N	\N
1382	7.75	7	0.20	10773	75	\N	\N
1383	12.50	70	0.20	10773	31	\N	\N
1384	39.00	33	0.00	10773	17	\N	\N
1385	17.00	50	0.00	10774	66	\N	\N
1386	12.50	2	0.25	10774	31	\N	\N
1387	14.00	3	0.00	10775	67	\N	\N
1388	31.00	6	0.00	10775	10	\N	\N
1389	53.00	120	0.05	10776	51	\N	\N
1390	9.50	27	0.05	10776	45	\N	\N
1391	14.00	12	0.05	10776	42	\N	\N
1392	12.50	16	0.05	10776	31	\N	\N
1393	14.00	20	0.20	10777	42	\N	\N
1394	9.65	10	0.00	10778	41	\N	\N
1395	49.30	20	0.00	10779	62	\N	\N
1396	17.45	20	0.00	10779	16	\N	\N
1397	13.00	15	0.00	10780	77	\N	\N
1398	15.00	35	0.00	10780	70	\N	\N
1399	10.00	35	0.00	10781	74	\N	\N
1400	38.00	20	0.20	10781	56	\N	\N
1401	7.45	3	0.20	10781	54	\N	\N
1402	12.50	1	0.00	10782	31	\N	\N
1403	263.50	5	0.00	10783	38	\N	\N
1404	12.50	10	0.00	10783	31	\N	\N
1405	34.80	30	0.15	10784	72	\N	\N
1406	18.00	2	0.15	10784	39	\N	\N
1407	19.00	30	0.00	10784	36	\N	\N
1408	7.75	10	0.00	10785	75	\N	\N
1409	31.00	10	0.00	10785	10	\N	\N
1410	7.75	42	0.20	10786	75	\N	\N
1411	25.89	15	0.20	10786	30	\N	\N
1412	40.00	30	0.20	10786	8	\N	\N
1413	123.79	20	0.05	10787	29	\N	\N
1414	19.00	15	0.05	10787	2	\N	\N
1415	7.75	40	0.05	10788	75	\N	\N
1416	9.20	50	0.05	10788	19	\N	\N
1417	12.50	18	0.00	10789	68	\N	\N
1418	43.90	30	0.00	10789	63	\N	\N
1419	18.00	15	0.00	10789	35	\N	\N
1420	62.50	30	0.00	10789	18	\N	\N
1421	38.00	20	0.15	10790	56	\N	\N
1422	30.00	3	0.15	10790	7	\N	\N
1423	9.65	20	0.05	10791	41	\N	\N
1424	123.79	14	0.05	10791	29	\N	\N
1425	12.50	15	0.00	10792	68	\N	\N
1426	7.45	3	0.00	10792	54	\N	\N
1427	19.00	10	0.00	10792	2	\N	\N
1428	7.00	8	0.00	10793	52	\N	\N
1429	9.65	14	0.00	10793	41	\N	\N
1430	7.45	6	0.20	10794	54	\N	\N
1431	23.25	15	0.20	10794	14	\N	\N
1432	39.00	35	0.25	10795	17	\N	\N
1433	17.45	65	0.00	10795	16	\N	\N
1434	36.00	24	0.20	10796	69	\N	\N
1435	33.25	35	0.20	10796	64	\N	\N
1436	19.45	10	0.00	10796	44	\N	\N
1437	31.23	21	0.20	10796	26	\N	\N
1438	21.00	20	0.00	10797	11	\N	\N
1439	34.80	10	0.00	10798	72	\N	\N
1440	49.30	2	0.00	10798	62	\N	\N
1441	55.00	25	0.00	10799	59	\N	\N
1442	4.50	20	0.15	10799	24	\N	\N
1443	6.00	20	0.15	10799	13	\N	\N
1444	7.45	7	0.10	10800	54	\N	\N
1445	53.00	10	0.10	10800	51	\N	\N
1446	21.00	50	0.10	10800	11	\N	\N
1447	123.79	20	0.25	10801	29	\N	\N
1448	39.00	40	0.25	10801	17	\N	\N
1449	49.30	5	0.25	10802	62	\N	\N
1450	24.00	60	0.25	10802	55	\N	\N
1451	53.00	30	0.25	10802	51	\N	\N
1452	25.89	25	0.25	10802	30	\N	\N
1453	55.00	15	0.05	10803	59	\N	\N
1454	14.00	15	0.05	10803	25	\N	\N
1455	9.20	24	0.05	10803	19	\N	\N
1456	20.00	4	0.15	10804	49	\N	\N
1457	45.60	24	0.00	10804	28	\N	\N
1458	31.00	36	0.00	10804	10	\N	\N
1459	263.50	10	0.00	10805	38	\N	\N
1460	14.00	10	0.00	10805	34	\N	\N
1461	10.00	15	0.25	10806	74	\N	\N
1462	21.05	2	0.00	10806	65	\N	\N
1463	19.00	20	0.25	10806	2	\N	\N
1464	18.40	1	0.00	10807	40	\N	\N
1465	18.00	50	0.15	10808	76	\N	\N
1466	38.00	20	0.15	10808	56	\N	\N
1467	7.00	20	0.00	10809	52	\N	\N
1468	15.00	5	0.00	10810	70	\N	\N
1469	14.00	5	0.00	10810	25	\N	\N
1470	6.00	7	0.00	10810	13	\N	\N
1471	18.40	30	0.00	10811	40	\N	\N
1472	9.00	18	0.00	10811	23	\N	\N
1473	9.20	15	0.00	10811	19	\N	\N
1474	13.00	20	0.00	10812	77	\N	\N
1475	34.80	40	0.10	10812	72	\N	\N
1476	12.50	16	0.10	10812	31	\N	\N
1477	12.00	35	0.00	10813	46	\N	\N
1478	19.00	12	0.20	10813	2	\N	\N
1479	28.50	30	0.15	10814	61	\N	\N
1480	12.75	8	0.15	10814	48	\N	\N
1481	46.00	20	0.15	10814	43	\N	\N
1482	9.65	20	0.00	10814	41	\N	\N
1483	2.50	16	0.00	10815	33	\N	\N
1484	49.30	20	0.05	10816	62	\N	\N
1485	263.50	30	0.05	10816	38	\N	\N
1486	49.30	25	0.15	10817	62	\N	\N
1487	18.40	60	0.15	10817	40	\N	\N
1488	263.50	30	0.00	10817	38	\N	\N
1489	31.23	40	0.15	10817	26	\N	\N
1490	9.65	20	0.00	10818	41	\N	\N
1491	32.00	20	0.00	10818	32	\N	\N
1492	7.75	20	0.00	10819	75	\N	\N
1493	46.00	7	0.00	10819	43	\N	\N
1494	38.00	30	0.00	10820	56	\N	\N
1495	53.00	6	0.00	10821	51	\N	\N
1496	18.00	20	0.00	10821	35	\N	\N
1497	15.00	6	0.00	10822	70	\N	\N
1498	49.30	3	0.00	10822	62	\N	\N
1499	13.00	15	0.10	10823	77	\N	\N
1500	55.00	40	0.10	10823	59	\N	\N
1501	19.50	15	0.00	10823	57	\N	\N
1502	21.00	20	0.10	10823	11	\N	\N
1503	15.00	9	0.00	10824	70	\N	\N
1504	9.65	12	0.00	10824	41	\N	\N
1505	32.80	20	0.00	10825	53	\N	\N
1506	31.23	12	0.00	10825	26	\N	\N
1507	19.50	15	0.00	10826	57	\N	\N
1508	12.50	35	0.00	10826	31	\N	\N
1509	18.00	21	0.00	10827	39	\N	\N
1510	31.00	15	0.00	10827	10	\N	\N
1511	263.50	2	0.00	10828	38	\N	\N
1512	81.00	5	0.00	10828	20	\N	\N
1513	34.00	21	0.00	10829	60	\N	\N
1514	6.00	10	0.00	10829	13	\N	\N
1515	40.00	20	0.00	10829	8	\N	\N
1516	19.00	10	0.00	10829	2	\N	\N
1517	12.50	24	0.00	10830	68	\N	\N
1518	34.00	30	0.00	10830	60	\N	\N
1519	18.00	28	0.00	10830	39	\N	\N
1520	25.00	6	0.00	10830	6	\N	\N
1521	46.00	9	0.00	10831	43	\N	\N
1522	263.50	8	0.00	10831	38	\N	\N
1523	18.00	8	0.00	10831	35	\N	\N
1524	9.20	2	0.00	10831	19	\N	\N
1525	33.25	3	0.00	10832	64	\N	\N
1526	19.45	16	0.20	10832	44	\N	\N
1527	14.00	10	0.20	10832	25	\N	\N
1528	6.00	3	0.20	10832	13	\N	\N
1529	32.80	9	0.10	10833	53	\N	\N
1530	12.50	9	0.10	10833	31	\N	\N
1531	30.00	20	0.10	10833	7	\N	\N
1532	25.89	20	0.05	10834	30	\N	\N
1533	123.79	8	0.05	10834	29	\N	\N
1534	13.00	2	0.20	10835	77	\N	\N
1535	55.00	15	0.00	10835	59	\N	\N
1536	33.25	30	0.00	10836	64	\N	\N
1537	34.00	60	0.00	10836	60	\N	\N
1538	19.50	24	0.00	10836	57	\N	\N
1539	18.00	6	0.00	10836	35	\N	\N
1540	21.00	52	0.00	10836	22	\N	\N
1541	18.00	21	0.25	10837	76	\N	\N
1542	9.50	40	0.25	10837	47	\N	\N
1543	18.40	25	0.00	10837	40	\N	\N
1544	6.00	6	0.00	10837	13	\N	\N
1545	19.00	50	0.25	10838	36	\N	\N
1546	62.50	25	0.25	10838	18	\N	\N
1547	18.00	4	0.25	10838	1	\N	\N
1548	34.80	15	0.10	10839	72	\N	\N
1549	13.25	30	0.10	10839	58	\N	\N
1550	18.00	10	0.20	10840	39	\N	\N
1551	14.00	6	0.20	10840	25	\N	\N
1552	13.00	15	0.00	10841	77	\N	\N
1553	55.00	50	0.00	10841	59	\N	\N
1554	38.00	30	0.00	10841	56	\N	\N
1555	31.00	16	0.00	10841	10	\N	\N
1556	15.00	12	0.00	10842	70	\N	\N
1557	12.50	20	0.00	10842	68	\N	\N
1558	46.00	5	0.00	10842	43	\N	\N
1559	21.00	15	0.00	10842	11	\N	\N
1560	53.00	4	0.25	10843	51	\N	\N
1561	21.00	35	0.00	10844	22	\N	\N
1562	33.25	48	0.00	10845	64	\N	\N
1563	13.25	60	0.10	10845	58	\N	\N
1564	14.00	42	0.10	10845	42	\N	\N
1565	18.00	25	0.10	10845	35	\N	\N
1566	9.00	70	0.10	10845	23	\N	\N
1567	10.00	20	0.00	10846	74	\N	\N
1568	15.00	30	0.00	10846	70	\N	\N
1569	22.00	21	0.00	10846	4	\N	\N
1570	21.50	55	0.20	10847	71	\N	\N
1571	34.00	45	0.20	10847	60	\N	\N
1572	9.50	36	0.20	10847	45	\N	\N
1573	26.00	60	0.20	10847	37	\N	\N
1574	9.20	12	0.20	10847	19	\N	\N
1575	18.00	80	0.20	10847	1	\N	\N
1576	97.00	3	0.00	10848	9	\N	\N
1577	21.35	30	0.00	10848	5	\N	\N
1578	31.23	18	0.15	10849	26	\N	\N
1579	10.00	49	0.00	10849	3	\N	\N
1580	15.00	30	0.15	10850	70	\N	\N
1581	2.50	4	0.15	10850	33	\N	\N
1582	14.00	20	0.15	10850	25	\N	\N
1583	55.00	42	0.05	10851	59	\N	\N
1584	19.50	10	0.05	10851	57	\N	\N
1585	14.00	10	0.05	10851	25	\N	\N
1586	19.00	5	0.05	10851	2	\N	\N
1587	49.30	50	0.00	10852	62	\N	\N
1588	39.00	6	0.00	10852	17	\N	\N
1589	19.00	15	0.00	10852	2	\N	\N
1590	62.50	10	0.00	10853	18	\N	\N
1591	6.00	65	0.15	10854	13	\N	\N
1592	31.00	100	0.15	10854	10	\N	\N
1593	21.05	15	0.15	10855	65	\N	\N
1594	38.00	24	0.00	10855	56	\N	\N
1595	12.50	14	0.00	10855	31	\N	\N
1596	17.45	50	0.00	10855	16	\N	\N
1597	14.00	20	0.00	10856	42	\N	\N
1598	19.00	20	0.00	10856	2	\N	\N
1599	123.79	10	0.25	10857	29	\N	\N
1600	31.23	35	0.25	10857	26	\N	\N
1601	10.00	30	0.00	10857	3	\N	\N
1602	15.00	4	0.00	10858	70	\N	\N
1603	43.90	10	0.00	10858	27	\N	\N
1604	30.00	5	0.00	10858	7	\N	\N
1605	33.25	30	0.25	10859	64	\N	\N
1606	7.45	35	0.25	10859	54	\N	\N
1607	4.50	40	0.25	10859	24	\N	\N
1608	18.00	20	0.00	10860	76	\N	\N
1609	53.00	3	0.00	10860	51	\N	\N
1610	49.30	3	0.00	10861	62	\N	\N
1611	2.50	35	0.00	10861	33	\N	\N
1612	10.00	40	0.00	10861	21	\N	\N
1613	62.50	20	0.00	10861	18	\N	\N
1614	39.00	42	0.00	10861	17	\N	\N
1615	7.00	8	0.00	10862	52	\N	\N
1616	21.00	25	0.00	10862	11	\N	\N
1617	13.25	12	0.15	10863	58	\N	\N
1618	18.00	20	0.15	10863	1	\N	\N
1619	14.00	15	0.00	10864	67	\N	\N
1620	18.00	4	0.00	10864	35	\N	\N
1621	18.00	80	0.05	10865	39	\N	\N
1622	263.50	60	0.05	10865	38	\N	\N
1623	25.89	40	0.25	10866	30	\N	\N
1624	4.50	6	0.25	10866	24	\N	\N
1625	19.00	21	0.25	10866	2	\N	\N
1626	32.80	3	0.00	10867	53	\N	\N
1627	20.00	42	0.10	10868	49	\N	\N
1628	18.00	30	0.00	10868	35	\N	\N
1629	31.23	20	0.00	10868	26	\N	\N
1630	12.50	20	0.00	10869	68	\N	\N
1631	9.00	50	0.00	10869	23	\N	\N
1632	21.00	10	0.00	10869	11	\N	\N
1633	18.00	40	0.00	10869	1	\N	\N
1634	53.00	2	0.00	10870	51	\N	\N
1635	18.00	3	0.00	10870	35	\N	\N
1636	39.00	16	0.05	10871	17	\N	\N
1637	17.45	12	0.05	10871	16	\N	\N
1638	25.00	50	0.05	10871	6	\N	\N
1639	21.05	21	0.05	10872	65	\N	\N
1640	33.25	15	0.05	10872	64	\N	\N
1641	49.30	20	0.05	10872	62	\N	\N
1642	24.00	10	0.05	10872	55	\N	\N
1643	45.60	3	0.00	10873	28	\N	\N
1644	10.00	20	0.00	10873	21	\N	\N
1645	31.00	10	0.00	10874	10	\N	\N
1646	20.00	15	0.00	10875	49	\N	\N
1647	9.50	21	0.10	10875	47	\N	\N
1648	9.20	25	0.00	10875	19	\N	\N
1649	33.25	20	0.00	10876	64	\N	\N
1650	12.00	21	0.00	10876	46	\N	\N
1651	62.50	25	0.00	10877	18	\N	\N
1652	17.45	30	0.25	10877	16	\N	\N
1653	81.00	20	0.05	10878	20	\N	\N
1654	18.00	10	0.00	10879	76	\N	\N
1655	21.05	10	0.00	10879	65	\N	\N
1656	18.40	12	0.00	10879	40	\N	\N
1657	15.00	50	0.20	10880	70	\N	\N
1658	28.50	30	0.20	10880	61	\N	\N
1659	9.00	30	0.20	10880	23	\N	\N
1660	15.00	10	0.00	10881	73	\N	\N
1661	7.45	32	0.15	10882	54	\N	\N
1662	20.00	20	0.15	10882	49	\N	\N
1663	14.00	25	0.00	10882	42	\N	\N
1664	4.50	8	0.00	10883	24	\N	\N
1665	21.05	12	0.05	10884	65	\N	\N
1666	38.00	21	0.05	10884	56	\N	\N
1667	10.00	40	0.05	10884	21	\N	\N
1668	13.00	25	0.00	10885	77	\N	\N
1669	15.00	30	0.00	10885	70	\N	\N
1670	4.50	12	0.00	10885	24	\N	\N
1671	19.00	20	0.00	10885	2	\N	\N
1672	13.00	40	0.00	10886	77	\N	\N
1673	12.50	35	0.00	10886	31	\N	\N
1674	31.00	70	0.00	10886	10	\N	\N
1675	14.00	5	0.00	10887	25	\N	\N
1676	12.50	18	0.00	10888	68	\N	\N
1677	19.00	20	0.00	10888	2	\N	\N
1678	263.50	40	0.00	10889	38	\N	\N
1679	21.00	40	0.00	10889	11	\N	\N
1680	9.65	14	0.00	10890	41	\N	\N
1681	14.00	10	0.00	10890	34	\N	\N
1682	39.00	15	0.00	10890	17	\N	\N
1683	25.89	15	0.05	10891	30	\N	\N
1684	55.00	40	0.05	10892	59	\N	\N
1685	19.00	20	0.00	10893	36	\N	\N
1686	25.89	35	0.00	10893	30	\N	\N
1687	123.79	24	0.00	10893	29	\N	\N
1688	4.50	10	0.00	10893	24	\N	\N
1689	40.00	30	0.00	10893	8	\N	\N
1690	7.75	120	0.05	10894	75	\N	\N
1691	36.00	50	0.05	10894	69	\N	\N
1692	6.00	28	0.05	10894	13	\N	\N
1693	34.00	100	0.00	10895	60	\N	\N
1694	18.40	91	0.00	10895	40	\N	\N
1695	18.00	45	0.00	10895	39	\N	\N
1696	4.50	110	0.00	10895	24	\N	\N
1697	38.00	16	0.00	10896	56	\N	\N
1698	9.50	15	0.00	10896	45	\N	\N
1699	25.89	36	0.00	10897	30	\N	\N
1700	123.79	80	0.00	10897	29	\N	\N
1701	6.00	5	0.00	10898	13	\N	\N
1702	18.00	8	0.15	10899	39	\N	\N
1703	15.00	3	0.25	10900	70	\N	\N
1704	21.50	30	0.00	10901	71	\N	\N
1705	9.65	30	0.00	10901	41	\N	\N
1706	49.30	6	0.15	10902	62	\N	\N
1707	24.00	30	0.15	10902	55	\N	\N
1708	12.50	20	0.00	10903	68	\N	\N
1709	21.05	21	0.00	10903	65	\N	\N
1710	6.00	40	0.00	10903	13	\N	\N
1711	49.30	35	0.00	10904	62	\N	\N
1712	13.25	15	0.00	10904	58	\N	\N
1713	18.00	20	0.05	10905	1	\N	\N
1714	28.50	15	0.00	10906	61	\N	\N
1715	7.75	14	0.00	10907	75	\N	\N
1716	7.00	14	0.05	10908	52	\N	\N
1717	30.00	20	0.05	10908	7	\N	\N
1718	9.65	5	0.00	10909	41	\N	\N
1719	17.45	15	0.00	10909	16	\N	\N
1720	30.00	12	0.00	10909	7	\N	\N
1721	28.50	5	0.00	10910	61	\N	\N
1722	20.00	10	0.00	10910	49	\N	\N
1723	9.20	12	0.00	10910	19	\N	\N
1724	14.00	15	0.00	10911	67	\N	\N
1725	39.00	12	0.00	10911	17	\N	\N
1726	18.00	10	0.00	10911	1	\N	\N
1727	123.79	60	0.25	10912	29	\N	\N
1728	21.00	40	0.25	10912	11	\N	\N
1729	13.25	15	0.00	10913	58	\N	\N
1730	2.50	40	0.25	10913	33	\N	\N
1731	22.00	30	0.25	10913	4	\N	\N
1732	21.50	25	0.00	10914	71	\N	\N
1733	7.45	10	0.00	10915	54	\N	\N
1734	2.50	30	0.00	10915	33	\N	\N
1735	39.00	10	0.00	10915	17	\N	\N
1736	19.50	20	0.00	10916	57	\N	\N
1737	32.00	6	0.00	10916	32	\N	\N
1738	17.45	6	0.00	10916	16	\N	\N
1739	34.00	10	0.00	10917	60	\N	\N
1740	25.89	1	0.00	10917	30	\N	\N
1741	34.00	25	0.25	10918	60	\N	\N
1742	18.00	60	0.25	10918	1	\N	\N
1743	18.40	20	0.00	10919	40	\N	\N
1744	14.00	24	0.00	10919	25	\N	\N
1745	17.45	24	0.00	10919	16	\N	\N
1746	16.25	24	0.00	10920	50	\N	\N
1747	43.90	40	0.00	10921	63	\N	\N
1748	18.00	10	0.00	10921	35	\N	\N
1749	4.50	35	0.00	10922	24	\N	\N
1750	39.00	15	0.00	10922	17	\N	\N
1751	14.00	24	0.20	10923	67	\N	\N
1752	46.00	10	0.20	10923	43	\N	\N
1753	14.00	10	0.20	10923	42	\N	\N
1754	7.75	6	0.00	10924	75	\N	\N
1755	45.60	30	0.10	10924	28	\N	\N
1756	31.00	20	0.10	10924	10	\N	\N
1757	7.00	12	0.15	10925	52	\N	\N
1758	19.00	25	0.15	10925	36	\N	\N
1759	34.80	10	0.00	10926	72	\N	\N
1760	9.20	7	0.00	10926	19	\N	\N
1761	6.00	10	0.00	10926	13	\N	\N
1762	21.00	2	0.00	10926	11	\N	\N
1763	18.00	20	0.00	10927	76	\N	\N
1764	7.00	5	0.00	10927	52	\N	\N
1765	81.00	5	0.00	10927	20	\N	\N
1766	18.00	5	0.00	10928	76	\N	\N
1767	9.50	5	0.00	10928	47	\N	\N
1768	13.00	15	0.00	10929	77	\N	\N
1769	7.75	49	0.00	10929	75	\N	\N
1770	10.00	60	0.00	10929	21	\N	\N
1771	13.25	30	0.20	10930	58	\N	\N
1772	24.00	25	0.20	10930	55	\N	\N
1773	43.90	25	0.00	10930	27	\N	\N
1774	10.00	36	0.00	10930	21	\N	\N
1775	19.50	30	0.00	10931	57	\N	\N
1776	6.00	42	0.15	10931	13	\N	\N
1777	7.75	20	0.10	10932	75	\N	\N
1778	34.80	16	0.00	10932	72	\N	\N
1779	49.30	14	0.10	10932	62	\N	\N
1780	17.45	30	0.10	10932	16	\N	\N
1781	28.50	30	0.00	10933	61	\N	\N
1782	32.80	2	0.00	10933	53	\N	\N
1783	25.00	20	0.00	10934	6	\N	\N
1784	9.00	8	0.25	10935	23	\N	\N
1785	62.50	4	0.25	10935	18	\N	\N
1786	18.00	21	0.00	10935	1	\N	\N
1787	19.00	30	0.20	10936	36	\N	\N
1788	14.00	20	0.00	10937	34	\N	\N
1789	45.60	8	0.00	10937	28	\N	\N
1790	21.50	35	0.25	10938	71	\N	\N
1791	34.00	49	0.25	10938	60	\N	\N
1792	46.00	24	0.25	10938	43	\N	\N
1793	6.00	20	0.25	10938	13	\N	\N
1794	14.00	40	0.15	10939	67	\N	\N
1795	19.00	10	0.15	10939	2	\N	\N
1796	6.00	20	0.00	10940	13	\N	\N
1797	30.00	8	0.00	10940	7	\N	\N
1798	34.80	50	0.00	10941	72	\N	\N
1799	12.50	80	0.25	10941	68	\N	\N
1800	49.30	30	0.25	10941	62	\N	\N
1801	12.50	44	0.25	10941	31	\N	\N
1802	20.00	28	0.00	10942	49	\N	\N
1803	12.00	15	0.00	10943	46	\N	\N
1804	21.00	21	0.00	10943	22	\N	\N
1805	6.00	15	0.00	10943	13	\N	\N
1806	38.00	18	0.00	10944	56	\N	\N
1807	19.45	18	0.25	10944	44	\N	\N
1808	21.00	5	0.25	10944	11	\N	\N
1809	12.50	10	0.00	10945	31	\N	\N
1810	6.00	20	0.00	10945	13	\N	\N
1811	13.00	40	0.00	10946	77	\N	\N
1812	4.50	25	0.00	10946	24	\N	\N
1813	31.00	25	0.00	10946	10	\N	\N
1814	55.00	4	0.00	10947	59	\N	\N
1815	24.00	4	0.00	10948	55	\N	\N
1816	53.00	40	0.00	10948	51	\N	\N
1817	16.25	9	0.00	10948	50	\N	\N
1818	49.30	60	0.00	10949	62	\N	\N
1819	39.00	6	0.00	10949	17	\N	\N
1820	31.00	30	0.00	10949	10	\N	\N
1821	25.00	12	0.00	10949	6	\N	\N
1822	22.00	5	0.00	10950	4	\N	\N
1823	7.75	50	0.05	10951	75	\N	\N
1824	9.65	6	0.05	10951	41	\N	\N
1825	2.50	15	0.05	10951	33	\N	\N
1826	45.60	2	0.00	10952	28	\N	\N
1827	25.00	16	0.05	10952	6	\N	\N
1828	12.50	50	0.05	10953	31	\N	\N
1829	81.00	50	0.05	10953	20	\N	\N
1830	34.00	24	0.15	10954	60	\N	\N
1831	9.50	30	0.00	10954	45	\N	\N
1832	12.50	25	0.15	10954	31	\N	\N
1833	17.45	28	0.15	10954	16	\N	\N
1834	7.75	12	0.20	10955	75	\N	\N
1835	53.00	8	0.00	10956	51	\N	\N
1836	9.50	14	0.00	10956	47	\N	\N
1837	10.00	12	0.00	10956	21	\N	\N
1838	33.25	8	0.00	10957	64	\N	\N
1839	18.00	40	0.00	10957	35	\N	\N
1840	25.89	30	0.00	10957	30	\N	\N
1841	34.80	5	0.00	10958	72	\N	\N
1842	30.00	6	0.00	10958	7	\N	\N
1843	21.35	20	0.00	10958	5	\N	\N
1844	7.75	20	0.15	10959	75	\N	\N
1845	9.65	24	0.00	10960	41	\N	\N
1846	4.50	10	0.25	10960	24	\N	\N
1847	18.00	60	0.00	10961	76	\N	\N
1848	7.00	6	0.05	10961	52	\N	\N
1849	18.00	44	0.00	10962	76	\N	\N
1850	36.00	9	0.00	10962	69	\N	\N
1851	32.80	20	0.00	10962	53	\N	\N
1852	6.00	77	0.00	10962	13	\N	\N
1853	30.00	45	0.00	10962	7	\N	\N
1854	34.00	2	0.15	10963	60	\N	\N
1855	36.00	10	0.00	10964	69	\N	\N
1856	263.50	5	0.00	10964	38	\N	\N
1857	62.50	6	0.00	10964	18	\N	\N
1858	53.00	16	0.00	10965	51	\N	\N
1859	49.30	12	0.15	10966	62	\N	\N
1860	38.00	12	0.15	10966	56	\N	\N
1861	26.00	8	0.00	10966	37	\N	\N
1862	20.00	40	0.00	10967	49	\N	\N
1863	9.20	12	0.00	10967	19	\N	\N
1864	33.25	4	0.00	10968	64	\N	\N
1865	4.50	30	0.00	10968	24	\N	\N
1866	38.00	30	0.00	10968	12	\N	\N
1867	12.00	9	0.00	10969	46	\N	\N
1868	7.00	40	0.20	10970	52	\N	\N
1869	123.79	14	0.00	10971	29	\N	\N
1870	2.50	7	0.00	10972	33	\N	\N
1871	39.00	6	0.00	10972	17	\N	\N
1872	7.75	10	0.00	10973	75	\N	\N
1873	9.65	6	0.00	10973	41	\N	\N
1874	31.23	5	0.00	10973	26	\N	\N
1875	43.90	10	0.00	10974	63	\N	\N
1876	7.75	10	0.00	10975	75	\N	\N
1877	40.00	16	0.00	10975	8	\N	\N
1878	45.60	20	0.00	10976	28	\N	\N
1879	43.90	20	0.00	10977	63	\N	\N
1880	53.00	10	0.00	10977	51	\N	\N
1881	9.50	30	0.00	10977	47	\N	\N
1882	18.00	30	0.00	10977	39	\N	\N
1883	19.45	6	0.15	10978	44	\N	\N
1884	18.40	10	0.00	10978	40	\N	\N
1885	10.00	40	0.15	10978	21	\N	\N
1886	40.00	20	0.15	10978	8	\N	\N
1887	43.90	35	0.00	10979	63	\N	\N
1888	12.50	24	0.00	10979	31	\N	\N
1889	43.90	30	0.00	10979	27	\N	\N
1890	4.50	80	0.00	10979	24	\N	\N
1891	38.00	20	0.00	10979	12	\N	\N
1892	30.00	18	0.00	10979	7	\N	\N
1893	7.75	40	0.20	10980	75	\N	\N
1894	263.50	60	0.00	10981	38	\N	\N
1895	46.00	9	0.00	10982	43	\N	\N
1896	30.00	20	0.00	10982	7	\N	\N
1897	19.50	15	0.00	10983	57	\N	\N
1898	6.00	84	0.15	10983	13	\N	\N
1899	19.00	40	0.00	10984	36	\N	\N
1900	4.50	20	0.00	10984	24	\N	\N
1901	17.45	55	0.00	10984	16	\N	\N
1902	32.00	35	0.10	10985	32	\N	\N
1903	62.50	8	0.10	10985	18	\N	\N
1904	17.45	36	0.10	10985	16	\N	\N
1905	13.00	15	0.00	10986	77	\N	\N
1906	18.00	10	0.00	10986	76	\N	\N
1907	81.00	15	0.00	10986	20	\N	\N
1908	21.00	30	0.00	10986	11	\N	\N
1909	34.80	20	0.00	10987	72	\N	\N
1910	46.00	6	0.00	10987	43	\N	\N
1911	30.00	60	0.00	10987	7	\N	\N
1912	49.30	40	0.10	10988	62	\N	\N
1913	30.00	60	0.00	10988	7	\N	\N
1914	9.65	4	0.00	10989	41	\N	\N
1915	21.00	15	0.00	10989	11	\N	\N
1916	25.00	40	0.00	10989	6	\N	\N
1917	28.50	66	0.15	10990	61	\N	\N
1918	24.00	65	0.15	10990	55	\N	\N
1919	14.00	60	0.15	10990	34	\N	\N
1920	10.00	65	0.00	10990	21	\N	\N
1921	18.00	90	0.20	10991	76	\N	\N
1922	15.00	20	0.20	10991	70	\N	\N
1923	19.00	50	0.20	10991	2	\N	\N
1924	34.80	2	0.00	10992	72	\N	\N
1925	9.65	35	0.25	10993	41	\N	\N
1926	123.79	50	0.25	10993	29	\N	\N
1927	55.00	18	0.05	10994	59	\N	\N
1928	34.00	4	0.00	10995	60	\N	\N
1929	53.00	20	0.00	10995	51	\N	\N
1930	14.00	40	0.00	10996	42	\N	\N
1931	7.00	20	0.25	10997	52	\N	\N
1932	12.00	20	0.25	10997	46	\N	\N
1933	32.00	50	0.00	10997	32	\N	\N
1934	7.75	30	0.00	10998	75	\N	\N
1935	10.00	20	0.00	10998	74	\N	\N
1936	28.50	7	0.00	10998	61	\N	\N
1937	4.50	12	0.00	10998	24	\N	\N
1938	13.00	21	0.05	10999	77	\N	\N
1939	53.00	15	0.05	10999	51	\N	\N
1940	9.65	20	0.05	10999	41	\N	\N
1941	13.00	30	0.00	11000	77	\N	\N
1942	4.50	30	0.25	11000	24	\N	\N
1943	22.00	25	0.25	11000	4	\N	\N
1944	24.00	6	0.00	11001	55	\N	\N
1945	12.00	25	0.00	11001	46	\N	\N
1946	21.00	25	0.00	11001	22	\N	\N
1947	30.00	60	0.00	11001	7	\N	\N
1948	24.00	40	0.00	11002	55	\N	\N
1949	14.00	24	0.15	11002	42	\N	\N
1950	18.00	15	0.15	11002	35	\N	\N
1951	6.00	56	0.00	11002	13	\N	\N
1952	7.00	10	0.00	11003	52	\N	\N
1953	18.40	10	0.00	11003	40	\N	\N
1954	18.00	4	0.00	11003	1	\N	\N
1955	18.00	6	0.00	11004	76	\N	\N
1956	31.23	6	0.00	11004	26	\N	\N
1957	55.00	10	0.00	11005	59	\N	\N
1958	18.00	2	0.00	11005	1	\N	\N
1959	123.79	2	0.25	11006	29	\N	\N
1960	18.00	8	0.00	11006	1	\N	\N
1961	14.00	14	0.00	11007	42	\N	\N
1962	123.79	10	0.00	11007	29	\N	\N
1963	40.00	30	0.00	11007	8	\N	\N
1964	21.50	21	0.00	11008	71	\N	\N
1965	14.00	90	0.05	11008	34	\N	\N
1966	45.60	70	0.05	11008	28	\N	\N
1967	34.00	9	0.00	11009	60	\N	\N
1968	19.00	18	0.25	11009	36	\N	\N
1969	4.50	12	0.00	11009	24	\N	\N
1970	4.50	10	0.00	11010	24	\N	\N
1971	30.00	20	0.00	11010	7	\N	\N
1972	21.50	20	0.00	11011	71	\N	\N
1973	13.25	40	0.05	11011	58	\N	\N
1974	21.50	60	0.05	11012	71	\N	\N
1975	34.00	36	0.05	11012	60	\N	\N
1976	9.20	50	0.05	11012	19	\N	\N
1977	12.50	2	0.00	11013	68	\N	\N
1978	9.50	20	0.00	11013	45	\N	\N
1979	14.00	4	0.00	11013	42	\N	\N
1980	9.00	10	0.00	11013	23	\N	\N
1981	9.65	28	0.10	11014	41	\N	\N
1982	13.00	18	0.00	11015	77	\N	\N
1983	25.89	15	0.00	11015	30	\N	\N
1984	19.00	16	0.00	11016	36	\N	\N
1985	12.50	15	0.00	11016	31	\N	\N
1986	15.00	30	0.00	11017	70	\N	\N
1987	55.00	110	0.00	11017	59	\N	\N
1988	10.00	25	0.00	11017	3	\N	\N
1989	38.00	5	0.00	11018	56	\N	\N
1990	62.50	10	0.00	11018	18	\N	\N
1991	38.00	20	0.00	11018	12	\N	\N
1992	20.00	2	0.00	11019	49	\N	\N
1993	12.00	3	0.00	11019	46	\N	\N
1994	31.00	24	0.15	11020	10	\N	\N
1995	34.80	35	0.00	11021	72	\N	\N
1996	53.00	44	0.25	11021	51	\N	\N
1997	31.23	63	0.00	11021	26	\N	\N
1998	81.00	15	0.00	11021	20	\N	\N
1999	19.00	11	0.25	11021	2	\N	\N
2000	36.00	30	0.00	11022	69	\N	\N
2001	9.20	35	0.00	11022	19	\N	\N
2002	46.00	30	0.00	11023	43	\N	\N
2003	30.00	4	0.00	11023	7	\N	\N
2004	21.50	50	0.00	11024	71	\N	\N
2005	21.05	21	0.00	11024	65	\N	\N
2006	2.50	30	0.00	11024	33	\N	\N
2007	31.23	12	0.00	11024	26	\N	\N
2008	6.00	20	0.10	11025	13	\N	\N
2009	18.00	10	0.10	11025	1	\N	\N
2010	53.00	10	0.00	11026	51	\N	\N
2011	62.50	8	0.00	11026	18	\N	\N
2012	49.30	21	0.25	11027	62	\N	\N
2013	4.50	30	0.25	11027	24	\N	\N
2014	55.00	24	0.00	11028	59	\N	\N
2015	24.00	35	0.00	11028	55	\N	\N
2016	43.90	12	0.00	11029	63	\N	\N
2017	38.00	20	0.00	11029	56	\N	\N
2018	55.00	100	0.25	11030	59	\N	\N
2019	123.79	60	0.25	11030	29	\N	\N
2020	21.35	70	0.00	11030	5	\N	\N
2021	19.00	100	0.25	11030	2	\N	\N
2022	21.50	16	0.00	11031	71	\N	\N
2023	33.25	20	0.00	11031	64	\N	\N
2024	4.50	21	0.00	11031	24	\N	\N
2025	6.00	80	0.00	11031	13	\N	\N
2026	18.00	45	0.00	11031	1	\N	\N
2027	55.00	30	0.00	11032	59	\N	\N
2028	263.50	25	0.00	11032	38	\N	\N
2029	19.00	35	0.00	11032	36	\N	\N
2030	36.00	36	0.10	11033	69	\N	\N
2031	32.80	70	0.10	11033	53	\N	\N
2032	28.50	6	0.00	11034	61	\N	\N
2033	19.45	12	0.00	11034	44	\N	\N
2034	10.00	15	0.10	11034	21	\N	\N
2035	7.45	10	0.00	11035	54	\N	\N
2036	14.00	30	0.00	11035	42	\N	\N
2037	18.00	60	0.00	11035	35	\N	\N
2038	18.00	10	0.00	11035	1	\N	\N
2039	55.00	30	0.00	11036	59	\N	\N
2040	6.00	7	0.00	11036	13	\N	\N
2041	15.00	4	0.00	11037	70	\N	\N
2042	21.50	30	0.00	11038	71	\N	\N
2043	7.00	2	0.00	11038	52	\N	\N
2044	18.40	5	0.20	11038	40	\N	\N
2045	19.50	28	0.00	11039	57	\N	\N
2046	20.00	60	0.00	11039	49	\N	\N
2047	18.00	24	0.00	11039	35	\N	\N
2048	45.60	20	0.00	11039	28	\N	\N
2049	10.00	20	0.00	11040	21	\N	\N
2050	43.90	30	0.00	11041	63	\N	\N
2051	19.00	30	0.20	11041	2	\N	\N
2052	28.50	4	0.00	11042	61	\N	\N
2053	19.45	15	0.00	11042	44	\N	\N
2054	21.00	10	0.00	11043	11	\N	\N
2055	49.30	12	0.00	11044	62	\N	\N
2056	53.00	24	0.00	11045	51	\N	\N
2057	2.50	15	0.00	11045	33	\N	\N
2058	18.00	18	0.05	11046	35	\N	\N
2059	32.00	15	0.05	11046	32	\N	\N
2060	38.00	20	0.05	11046	12	\N	\N
2061	21.35	30	0.25	11047	5	\N	\N
2062	18.00	25	0.25	11047	1	\N	\N
2063	12.50	42	0.00	11048	68	\N	\N
2064	38.00	4	0.20	11049	12	\N	\N
2065	19.00	10	0.20	11049	2	\N	\N
2066	18.00	50	0.10	11050	76	\N	\N
2067	4.50	10	0.20	11051	24	\N	\N
2068	28.50	10	0.20	11052	61	\N	\N
2069	46.00	30	0.20	11052	43	\N	\N
2070	33.25	25	0.20	11053	64	\N	\N
2071	32.00	20	0.00	11053	32	\N	\N
2072	62.50	35	0.20	11053	18	\N	\N
2073	14.00	20	0.00	11054	67	\N	\N
2074	2.50	10	0.00	11054	33	\N	\N
2075	19.50	20	0.00	11055	57	\N	\N
2076	53.00	20	0.00	11055	51	\N	\N
2077	14.00	15	0.00	11055	25	\N	\N
2078	4.50	15	0.00	11055	24	\N	\N
2079	34.00	50	0.00	11056	60	\N	\N
2080	24.00	35	0.00	11056	55	\N	\N
2081	30.00	40	0.00	11056	7	\N	\N
2082	15.00	3	0.00	11057	70	\N	\N
2083	28.50	4	0.00	11058	61	\N	\N
2084	34.00	21	0.00	11058	60	\N	\N
2085	10.00	3	0.00	11058	21	\N	\N
2086	34.00	35	0.00	11059	60	\N	\N
2087	39.00	12	0.00	11059	17	\N	\N
2088	6.00	30	0.00	11059	13	\N	\N
2089	13.00	10	0.00	11060	77	\N	\N
2090	34.00	4	0.00	11060	60	\N	\N
2091	34.00	15	0.00	11061	60	\N	\N
2092	15.00	12	0.20	11062	70	\N	\N
2093	32.80	10	0.20	11062	53	\N	\N
2094	9.65	30	0.10	11063	41	\N	\N
2095	18.40	40	0.10	11063	40	\N	\N
2096	14.00	30	0.00	11063	34	\N	\N
2097	12.50	55	0.00	11064	68	\N	\N
2098	24.00	4	0.10	11064	55	\N	\N
2099	32.80	25	0.10	11064	53	\N	\N
2100	9.65	12	0.00	11064	41	\N	\N
2101	39.00	77	0.10	11064	17	\N	\N
2102	7.45	20	0.25	11065	54	\N	\N
2103	25.89	4	0.25	11065	30	\N	\N
2104	14.00	35	0.00	11066	34	\N	\N
2105	9.20	42	0.00	11066	19	\N	\N
2106	17.45	3	0.00	11066	16	\N	\N
2107	9.65	9	0.00	11067	41	\N	\N
2108	13.00	28	0.15	11068	77	\N	\N
2109	46.00	36	0.15	11068	43	\N	\N
2110	45.60	8	0.15	11068	28	\N	\N
2111	18.00	20	0.00	11069	39	\N	\N
2112	12.50	20	0.00	11070	31	\N	\N
2113	17.45	30	0.15	11070	16	\N	\N
2114	19.00	20	0.15	11070	2	\N	\N
2115	18.00	40	0.15	11070	1	\N	\N
2116	6.00	10	0.05	11071	13	\N	\N
2117	30.00	15	0.05	11071	7	\N	\N
2118	33.25	130	0.00	11072	64	\N	\N
2119	16.25	22	0.00	11072	50	\N	\N
2120	9.65	40	0.00	11072	41	\N	\N
2121	19.00	8	0.00	11072	2	\N	\N
2122	4.50	20	0.00	11073	24	\N	\N
2123	21.00	10	0.00	11073	11	\N	\N
2124	17.45	14	0.05	11074	16	\N	\N
2125	18.00	2	0.15	11075	76	\N	\N
2126	12.00	30	0.15	11075	46	\N	\N
2127	19.00	10	0.15	11075	2	\N	\N
2128	9.20	10	0.25	11076	19	\N	\N
2129	23.25	20	0.25	11076	14	\N	\N
2130	25.00	20	0.25	11076	6	\N	\N
2131	22.00	1	0.00	11077	4	\N	\N
2132	10.00	4	0.00	11077	3	\N	\N
2133	19.00	24	0.20	11077	2	\N	\N
2134	13.00	2	0.00	11077	77	\N	\N
2135	7.75	4	0.00	11077	75	\N	\N
2136	15.00	2	0.01	11077	73	\N	\N
2137	17.00	1	0.00	11077	66	\N	\N
2138	33.25	2	0.03	11077	64	\N	\N
2139	34.00	2	0.06	11077	60	\N	\N
2140	24.00	2	0.00	11077	55	\N	\N
2141	7.00	2	0.00	11077	52	\N	\N
2142	12.00	3	0.02	11077	46	\N	\N
2143	9.65	3	0.00	11077	41	\N	\N
2144	18.00	2	0.05	11077	39	\N	\N
2145	32.00	1	0.00	11077	32	\N	\N
2146	9.00	2	0.00	11077	23	\N	\N
2147	81.00	1	0.04	11077	20	\N	\N
2148	17.45	2	0.03	11077	16	\N	\N
2149	23.25	1	0.03	11077	14	\N	\N
2150	6.00	4	0.00	11077	13	\N	\N
2151	38.00	2	0.05	11077	12	\N	\N
2152	31.00	1	0.00	11077	10	\N	\N
2153	40.00	2	0.10	11077	8	\N	\N
2154	30.00	1	0.05	11077	7	\N	\N
2155	25.00	1	0.02	11077	6	\N	\N
\.


--
-- Name: order_details_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('order_details_id_seq', 2155, true);


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY orders (id, order_date, required_date, shipped_date, ship_via_id, freight, ship_name, ship_address, ship_city, ship_region, ship_postal_code, ship_country, customer_code, customer_id, employee_id, created_at, updated_at) FROM stdin;
11005	1998-04-07	1998-05-05	1998-04-10	1	0.75	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland	WILMK	90	2	\N	\N
10248	1996-07-04	1996-08-01	1996-07-16	3	32.38	Vins et alcools Chevalier	59 rue de l-Abbaye	Reims	\N	51100	France	VINET	85	5	\N	\N
10249	1996-07-05	1996-08-16	1996-07-10	1	11.61	Toms Spezialitäten	Luisenstr. 48	Münster	\N	44087	Germany	TOMSP	79	6	\N	\N
10250	1996-07-08	1996-08-05	1996-07-12	2	65.83	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	4	\N	\N
10251	1996-07-08	1996-08-05	1996-07-15	1	41.34	Victuailles en stock	2, rue du Commerce	Lyon	\N	69004	France	VICTE	84	3	\N	\N
10252	1996-07-09	1996-08-06	1996-07-11	2	51.3	Suprêmes délices	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	SUPRD	76	4	\N	\N
10253	1996-07-10	1996-07-24	1996-07-16	2	58.17	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	3	\N	\N
10254	1996-07-11	1996-08-08	1996-07-23	2	22.98	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland	CHOPS	14	5	\N	\N
10255	1996-07-12	1996-08-09	1996-07-15	3	148.33	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland	RICSU	68	9	\N	\N
10256	1996-07-15	1996-08-12	1996-07-17	2	13.97	Wellington Importadora	Rua do Mercado, 12	Resende	SP	08737-363	Brazil	WELLI	88	3	\N	\N
10257	1996-07-16	1996-08-13	1996-07-22	3	81.91	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	4	\N	\N
10258	1996-07-17	1996-08-14	1996-07-23	1	140.51	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	1	\N	\N
10259	1996-07-18	1996-08-15	1996-07-25	3	3.25	Centro comercial Moctezuma	Sierras de Granada 9993	México D.F.	\N	5022	Mexico	CENTC	13	4	\N	\N
10260	1996-07-19	1996-08-16	1996-07-29	1	55.09	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany	OTTIK	56	4	\N	\N
10261	1996-07-19	1996-08-16	1996-07-30	2	3.05	Que Delícia	Rua da Panificadora, 12	Rio de Janeiro	RJ	02389-673	Brazil	QUEDE	61	4	\N	\N
10262	1996-07-22	1996-08-19	1996-07-25	3	48.29	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	8	\N	\N
10263	1996-07-23	1996-08-20	1996-07-31	3	146.06	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	9	\N	\N
10264	1996-07-24	1996-08-21	1996-08-23	3	3.67	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	6	\N	\N
10265	1996-07-25	1996-08-22	1996-08-12	1	55.28	Blondel père et fils	24, place Kléber	Strasbourg	\N	67000	France	BLONP	7	2	\N	\N
10266	1996-07-26	1996-09-06	1996-07-31	3	25.73	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	3	\N	\N
10267	1996-07-29	1996-08-26	1996-08-06	1	208.58	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	4	\N	\N
10268	1996-07-30	1996-08-27	1996-08-02	3	66.29	GROSELLA-Restaurante	5ª Ave. Los Palos Grandes	Caracas	DF	1081	Venezuela	GROSR	33	8	\N	\N
10269	1996-07-31	1996-08-14	1996-08-09	1	4.56	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	5	\N	\N
10270	1996-08-01	1996-08-29	1996-08-02	1	136.54	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	1	\N	\N
10271	1996-08-01	1996-08-29	1996-08-30	2	4.54	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA	SPLIR	75	6	\N	\N
10272	1996-08-02	1996-08-30	1996-08-06	2	98.03	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	6	\N	\N
10273	1996-08-05	1996-09-02	1996-08-12	3	76.07	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	3	\N	\N
10274	1996-08-06	1996-09-03	1996-08-16	1	6.01	Vins et alcools Chevalier	59 rue de l-Abbaye	Reims	\N	51100	France	VINET	85	6	\N	\N
10275	1996-08-07	1996-09-04	1996-08-09	1	26.93	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy	MAGAA	49	1	\N	\N
10276	1996-08-08	1996-08-22	1996-08-14	3	13.84	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico	TORTU	80	8	\N	\N
10277	1996-08-09	1996-09-06	1996-08-13	3	125.77	Morgenstern Gesundkost	Heerstr. 22	Leipzig	\N	4179	Germany	MORGK	52	2	\N	\N
10278	1996-08-12	1996-09-09	1996-08-16	2	92.69	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	8	\N	\N
10279	1996-08-13	1996-09-10	1996-08-16	2	25.83	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	8	\N	\N
10280	1996-08-14	1996-09-11	1996-09-12	1	8.98	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	2	\N	\N
10281	1996-08-14	1996-08-28	1996-08-21	1	2.94	Romero y tomillo	Gran Vía, 1	Madrid	\N	28001	Spain	ROMEY	69	4	\N	\N
10282	1996-08-15	1996-09-12	1996-08-21	1	12.69	Romero y tomillo	Gran Vía, 1	Madrid	\N	28001	Spain	ROMEY	69	4	\N	\N
10283	1996-08-16	1996-09-13	1996-08-23	3	84.81	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	3	\N	\N
10284	1996-08-19	1996-09-16	1996-08-27	1	76.56	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	4	\N	\N
10285	1996-08-20	1996-09-17	1996-08-26	2	76.83	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	1	\N	\N
10286	1996-08-21	1996-09-18	1996-08-30	3	229.24	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	8	\N	\N
10287	1996-08-22	1996-09-19	1996-08-28	3	12.76	Ricardo Adocicados	Av. Copacabana, 267	Rio de Janeiro	RJ	02389-890	Brazil	RICAR	67	8	\N	\N
10288	1996-08-23	1996-09-20	1996-09-03	1	7.45	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	REGGC	66	4	\N	\N
10289	1996-08-26	1996-09-23	1996-08-28	3	22.77	B-s Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK	BSBEV	11	7	\N	\N
10290	1996-08-27	1996-09-24	1996-09-03	1	79.7	Comércio Mineiro	Av. dos Lusíadas, 23	Sao Paulo	SP	05432-043	Brazil	COMMI	15	8	\N	\N
10291	1996-08-27	1996-09-24	1996-09-04	2	6.4	Que Delícia	Rua da Panificadora, 12	Rio de Janeiro	RJ	02389-673	Brazil	QUEDE	61	6	\N	\N
10292	1996-08-28	1996-09-25	1996-09-02	2	1.35	Tradiçao Hipermercados	Av. Inês de Castro, 414	Sao Paulo	SP	05634-030	Brazil	TRADH	81	1	\N	\N
10293	1996-08-29	1996-09-26	1996-09-11	3	21.18	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico	TORTU	80	1	\N	\N
10294	1996-08-30	1996-09-27	1996-09-05	2	147.26	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	4	\N	\N
10295	1996-09-02	1996-09-30	1996-09-10	2	1.15	Vins et alcools Chevalier	59 rue de l-Abbaye	Reims	\N	51100	France	VINET	85	2	\N	\N
10296	1996-09-03	1996-10-01	1996-09-11	1	0.12	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	6	\N	\N
10297	1996-09-04	1996-10-16	1996-09-10	2	5.74	Blondel père et fils	24, place Kléber	Strasbourg	\N	67000	France	BLONP	7	5	\N	\N
10298	1996-09-05	1996-10-03	1996-09-11	2	168.22	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	6	\N	\N
10299	1996-09-06	1996-10-04	1996-09-13	2	29.76	Ricardo Adocicados	Av. Copacabana, 267	Rio de Janeiro	RJ	02389-890	Brazil	RICAR	67	4	\N	\N
10300	1996-09-09	1996-10-07	1996-09-18	2	17.68	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy	MAGAA	49	2	\N	\N
10301	1996-09-09	1996-10-07	1996-09-17	2	45.08	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany	WANDK	86	8	\N	\N
10302	1996-09-10	1996-10-08	1996-10-09	2	6.27	Suprêmes délices	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	SUPRD	76	4	\N	\N
10303	1996-09-11	1996-10-09	1996-09-18	2	107.83	Godos Cocina Típica	C/ Romero, 33	Sevilla	\N	41101	Spain	GODOS	30	7	\N	\N
10304	1996-09-12	1996-10-10	1996-09-17	2	63.79	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico	TORTU	80	1	\N	\N
10305	1996-09-13	1996-10-11	1996-10-09	3	257.62	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA	OLDWO	55	8	\N	\N
10306	1996-09-16	1996-10-14	1996-09-23	3	7.56	Romero y tomillo	Gran Vía, 1	Madrid	\N	28001	Spain	ROMEY	69	1	\N	\N
10307	1996-09-17	1996-10-15	1996-09-25	2	0.56	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA	LONEP	48	2	\N	\N
10308	1996-09-18	1996-10-16	1996-09-24	3	1.61	Ana Trujillo Emparedados y helados	Avda. de la Constitución 2222	México D.F.	\N	5021	Mexico	ANATR	2	7	\N	\N
10309	1996-09-19	1996-10-17	1996-10-23	1	47.3	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	3	\N	\N
10310	1996-09-20	1996-10-18	1996-09-27	2	17.52	The Big Cheese	89 Jefferson Way Suite 2	Portland	OR	97201	USA	THEBI	77	8	\N	\N
10311	1996-09-20	1996-10-04	1996-09-26	3	24.69	Du monde entier	67, rue des Cinquante Otages	Nantes	\N	44000	France	DUMON	18	1	\N	\N
10312	1996-09-23	1996-10-21	1996-10-03	2	40.26	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany	WANDK	86	2	\N	\N
10313	1996-09-24	1996-10-22	1996-10-04	2	1.96	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	2	\N	\N
10314	1996-09-25	1996-10-23	1996-10-04	2	74.16	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	1	\N	\N
10315	1996-09-26	1996-10-24	1996-10-03	2	41.76	Island Trading	Garden House Crowther Way	Cowes	Isle of Wight	PO31 7PJ	UK	ISLAT	38	4	\N	\N
10316	1996-09-27	1996-10-25	1996-10-08	3	150.15	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	1	\N	\N
10317	1996-09-30	1996-10-28	1996-10-10	1	12.69	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA	LONEP	48	6	\N	\N
10318	1996-10-01	1996-10-29	1996-10-04	2	4.73	Island Trading	Garden House Crowther Way	Cowes	Isle of Wight	PO31 7PJ	UK	ISLAT	38	8	\N	\N
10319	1996-10-02	1996-10-30	1996-10-11	3	64.5	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico	TORTU	80	7	\N	\N
10320	1996-10-03	1996-10-17	1996-10-18	3	34.57	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	5	\N	\N
10321	1996-10-03	1996-10-31	1996-10-11	2	3.43	Island Trading	Garden House Crowther Way	Cowes	Isle of Wight	PO31 7PJ	UK	ISLAT	38	3	\N	\N
10322	1996-10-04	1996-11-01	1996-10-23	3	0.4	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	México D.F.	\N	5033	Mexico	PERIC	58	7	\N	\N
10323	1996-10-07	1996-11-04	1996-10-14	1	4.88	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	4	\N	\N
10324	1996-10-08	1996-11-05	1996-10-10	1	214.27	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	9	\N	\N
10325	1996-10-09	1996-10-23	1996-10-14	3	64.86	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	1	\N	\N
10326	1996-10-10	1996-11-07	1996-10-14	2	77.92	Bólido Comidas preparadas	C/ Araquil, 67	Madrid	\N	28023	Spain	BOLID	8	4	\N	\N
10327	1996-10-11	1996-11-08	1996-10-14	1	63.36	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	2	\N	\N
10328	1996-10-14	1996-11-11	1996-10-17	3	87.03	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal	FURIB	28	4	\N	\N
10329	1996-10-15	1996-11-26	1996-10-23	2	191.67	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA	SPLIR	75	4	\N	\N
10330	1996-10-16	1996-11-13	1996-10-28	1	12.75	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	3	\N	\N
10331	1996-10-16	1996-11-27	1996-10-21	1	10.19	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	9	\N	\N
10332	1996-10-17	1996-11-28	1996-10-21	2	52.84	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	3	\N	\N
10333	1996-10-18	1996-11-15	1996-10-25	3	0.59	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	5	\N	\N
10334	1996-10-21	1996-11-18	1996-10-28	2	8.56	Victuailles en stock	2, rue du Commerce	Lyon	\N	69004	France	VICTE	84	8	\N	\N
10335	1996-10-22	1996-11-19	1996-10-24	2	42.11	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	7	\N	\N
10336	1996-10-23	1996-11-20	1996-10-25	2	15.51	Princesa Isabel Vinhos	Estrada da saúde n. 58	Lisboa	\N	1756	Portugal	PRINI	60	7	\N	\N
10337	1996-10-24	1996-11-21	1996-10-29	3	108.26	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	4	\N	\N
10338	1996-10-25	1996-11-22	1996-10-29	3	84.21	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA	OLDWO	55	4	\N	\N
10339	1996-10-28	1996-11-25	1996-11-04	2	15.66	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	2	\N	\N
10340	1996-10-29	1996-11-26	1996-11-08	3	166.31	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	1	\N	\N
10341	1996-10-29	1996-11-26	1996-11-05	3	26.78	Simons bistro	Vinbæltet 34	Kobenhavn	\N	1734	Denmark	SIMOB	73	7	\N	\N
10342	1996-10-30	1996-11-13	1996-11-04	2	54.83	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	4	\N	\N
10343	1996-10-31	1996-11-28	1996-11-06	1	110.37	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	4	\N	\N
10344	1996-11-01	1996-11-29	1996-11-05	2	23.29	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	4	\N	\N
10345	1996-11-04	1996-12-02	1996-11-11	2	249.06	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	2	\N	\N
10346	1996-11-05	1996-12-17	1996-11-08	3	142.08	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	3	\N	\N
10347	1996-11-06	1996-12-04	1996-11-08	3	3.1	Familia Arquibaldo	Rua Orós, 92	Sao Paulo	SP	05442-030	Brazil	FAMIA	21	4	\N	\N
10348	1996-11-07	1996-12-05	1996-11-15	2	0.78	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany	WANDK	86	4	\N	\N
10349	1996-11-08	1996-12-06	1996-11-15	1	8.63	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA	SPLIR	75	7	\N	\N
10350	1996-11-11	1996-12-09	1996-12-03	2	64.19	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	6	\N	\N
10351	1996-11-11	1996-12-09	1996-11-20	1	162.33	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	1	\N	\N
10352	1996-11-12	1996-11-26	1996-11-18	3	1.3	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal	FURIB	28	3	\N	\N
10353	1996-11-13	1996-12-11	1996-11-25	3	360.63	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria	PICCO	59	7	\N	\N
10354	1996-11-14	1996-12-12	1996-11-20	3	53.8	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	México D.F.	\N	5033	Mexico	PERIC	58	8	\N	\N
10355	1996-11-15	1996-12-13	1996-11-20	1	41.95	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	6	\N	\N
10356	1996-11-18	1996-12-16	1996-11-27	2	36.71	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany	WANDK	86	6	\N	\N
10357	1996-11-19	1996-12-17	1996-12-02	3	34.88	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	1	\N	\N
10358	1996-11-20	1996-12-18	1996-11-27	1	19.64	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	5	\N	\N
10359	1996-11-21	1996-12-19	1996-11-26	3	288.43	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK	SEVES	72	5	\N	\N
10360	1996-11-22	1996-12-20	1996-12-02	3	131.7	Blondel père et fils	24, place Kléber	Strasbourg	\N	67000	France	BLONP	7	4	\N	\N
10361	1996-11-22	1996-12-20	1996-12-03	2	183.17	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	1	\N	\N
10362	1996-11-25	1996-12-23	1996-11-28	1	96.04	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	3	\N	\N
10363	1996-11-26	1996-12-24	1996-12-04	3	30.54	Drachenblut Delikatessen	Walserweg 21	Aachen	\N	52066	Germany	DRACD	17	4	\N	\N
10364	1996-11-26	1997-01-07	1996-12-04	1	71.97	Eastern Connection	35 King George	London	\N	WX3 6FW	UK	EASTC	19	1	\N	\N
10365	1996-11-27	1996-12-25	1996-12-02	2	22	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico	ANTON	3	3	\N	\N
10366	1996-11-28	1997-01-09	1996-12-30	2	10.14	Galería del gastronómo	Rambla de Cataluña, 23	Barcelona	\N	8022	Spain	GALED	29	8	\N	\N
10367	1996-11-28	1996-12-26	1996-12-02	3	13.55	Vaffeljernet	Smagsloget 45	Århus	\N	8200	Denmark	VAFFE	83	7	\N	\N
10368	1996-11-29	1996-12-27	1996-12-02	2	101.95	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	2	\N	\N
10369	1996-12-02	1996-12-30	1996-12-09	2	195.68	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA	SPLIR	75	8	\N	\N
10370	1996-12-03	1996-12-31	1996-12-27	2	1.17	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland	CHOPS	14	6	\N	\N
10371	1996-12-03	1996-12-31	1996-12-24	1	0.45	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	1	\N	\N
10372	1996-12-04	1997-01-01	1996-12-09	2	890.78	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	5	\N	\N
10373	1996-12-05	1997-01-02	1996-12-11	3	124.12	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	4	\N	\N
10374	1996-12-05	1997-01-02	1996-12-09	3	3.94	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland	WOLZA	91	1	\N	\N
10375	1996-12-06	1997-01-03	1996-12-09	2	20.12	Hungry Coyote Import Store	City Center Plaza 516 Main St.	Elgin	OR	97827	USA	HUNGC	36	3	\N	\N
10376	1996-12-09	1997-01-06	1996-12-13	2	20.39	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	1	\N	\N
10377	1996-12-09	1997-01-06	1996-12-13	3	22.21	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK	SEVES	72	1	\N	\N
10378	1996-12-10	1997-01-07	1996-12-19	3	5.44	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	5	\N	\N
10379	1996-12-11	1997-01-08	1996-12-13	1	45.03	Que Delícia	Rua da Panificadora, 12	Rio de Janeiro	RJ	02389-673	Brazil	QUEDE	61	2	\N	\N
10380	1996-12-12	1997-01-09	1997-01-16	3	35.03	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	8	\N	\N
10381	1996-12-12	1997-01-09	1996-12-13	3	7.99	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	3	\N	\N
10382	1996-12-13	1997-01-10	1996-12-16	1	94.77	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	4	\N	\N
10383	1996-12-16	1997-01-13	1996-12-18	3	34.24	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	8	\N	\N
10384	1996-12-16	1997-01-13	1996-12-20	3	168.64	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	3	\N	\N
10385	1996-12-17	1997-01-14	1996-12-23	2	30.96	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA	SPLIR	75	1	\N	\N
10386	1996-12-18	1997-01-01	1996-12-25	3	13.99	Familia Arquibaldo	Rua Orós, 92	Sao Paulo	SP	05442-030	Brazil	FAMIA	21	9	\N	\N
10387	1996-12-18	1997-01-15	1996-12-20	2	93.63	Santé Gourmet	Erling Skakkes gate 78	Stavern	\N	4110	Norway	SANTG	70	1	\N	\N
10388	1996-12-19	1997-01-16	1996-12-20	1	34.86	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK	SEVES	72	2	\N	\N
10389	1996-12-20	1997-01-17	1996-12-24	2	47.42	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	4	\N	\N
10390	1996-12-23	1997-01-20	1996-12-26	1	126.38	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	6	\N	\N
10391	1996-12-23	1997-01-20	1996-12-31	3	5.45	Drachenblut Delikatessen	Walserweg 21	Aachen	\N	52066	Germany	DRACD	17	3	\N	\N
10392	1996-12-24	1997-01-21	1997-01-01	3	122.46	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria	PICCO	59	2	\N	\N
10393	1996-12-25	1997-01-22	1997-01-03	3	126.56	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	1	\N	\N
10394	1996-12-25	1997-01-22	1997-01-03	3	30.34	Hungry Coyote Import Store	City Center Plaza 516 Main St.	Elgin	OR	97827	USA	HUNGC	36	1	\N	\N
10395	1996-12-26	1997-01-23	1997-01-03	1	184.41	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	6	\N	\N
10396	1996-12-27	1997-01-10	1997-01-06	3	135.35	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	1	\N	\N
10397	1996-12-27	1997-01-24	1997-01-02	1	60.26	Princesa Isabel Vinhos	Estrada da saúde n. 58	Lisboa	\N	1756	Portugal	PRINI	60	5	\N	\N
10398	1996-12-30	1997-01-27	1997-01-09	3	89.16	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	2	\N	\N
10399	1996-12-31	1997-01-14	1997-01-08	3	27.36	Vaffeljernet	Smagsloget 45	Århus	\N	8200	Denmark	VAFFE	83	8	\N	\N
10400	1997-01-01	1997-01-29	1997-01-16	3	83.93	Eastern Connection	35 King George	London	\N	WX3 6FW	UK	EASTC	19	1	\N	\N
10401	1997-01-01	1997-01-29	1997-01-10	1	12.51	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	1	\N	\N
10402	1997-01-02	1997-02-13	1997-01-10	2	67.88	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	8	\N	\N
10403	1997-01-03	1997-01-31	1997-01-09	3	73.79	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	4	\N	\N
10404	1997-01-03	1997-01-31	1997-01-08	1	155.97	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy	MAGAA	49	2	\N	\N
10405	1997-01-06	1997-02-03	1997-01-22	1	34.82	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	LINOD	47	1	\N	\N
10406	1997-01-07	1997-02-18	1997-01-13	1	108.04	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	7	\N	\N
10407	1997-01-07	1997-02-04	1997-01-30	2	91.48	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany	OTTIK	56	2	\N	\N
10408	1997-01-08	1997-02-05	1997-01-14	1	11.26	Folies gourmandes	184, chaussée de Tournai	Lille	\N	59000	France	FOLIG	23	8	\N	\N
10409	1997-01-09	1997-02-06	1997-01-14	1	29.83	Océano Atlántico Ltda.	Ing. Gustavo Moncada 8585 Piso 20-A	Buenos Aires	\N	1010	Argentina	OCEAN	54	3	\N	\N
10410	1997-01-10	1997-02-07	1997-01-15	3	2.4	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	3	\N	\N
10411	1997-01-10	1997-02-07	1997-01-21	3	23.65	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	9	\N	\N
10412	1997-01-13	1997-02-10	1997-01-15	2	3.77	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	8	\N	\N
10413	1997-01-14	1997-02-11	1997-01-16	2	95.66	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	3	\N	\N
10414	1997-01-14	1997-02-11	1997-01-17	3	21.48	Familia Arquibaldo	Rua Orós, 92	Sao Paulo	SP	05442-030	Brazil	FAMIA	21	2	\N	\N
10415	1997-01-15	1997-02-12	1997-01-24	1	0.2	Hungry Coyote Import Store	City Center Plaza 516 Main St.	Elgin	OR	97827	USA	HUNGC	36	3	\N	\N
10416	1997-01-16	1997-02-13	1997-01-27	3	22.72	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	8	\N	\N
10417	1997-01-16	1997-02-13	1997-01-28	3	70.29	Simons bistro	Vinbæltet 34	Kobenhavn	\N	1734	Denmark	SIMOB	73	4	\N	\N
10418	1997-01-17	1997-02-14	1997-01-24	1	17.55	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	4	\N	\N
10419	1997-01-20	1997-02-17	1997-01-30	2	137.35	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland	RICSU	68	4	\N	\N
10420	1997-01-21	1997-02-18	1997-01-27	1	44.12	Wellington Importadora	Rua do Mercado, 12	Resende	SP	08737-363	Brazil	WELLI	88	3	\N	\N
10421	1997-01-21	1997-03-04	1997-01-27	1	99.23	Que Delícia	Rua da Panificadora, 12	Rio de Janeiro	RJ	02389-673	Brazil	QUEDE	61	8	\N	\N
10422	1997-01-22	1997-02-19	1997-01-31	1	3.02	Franchi S.p.A.	Via Monte Bianco 34	Torino	\N	10100	Italy	FRANS	27	2	\N	\N
10423	1997-01-23	1997-02-06	1997-02-24	3	24.5	Gourmet Lanchonetes	Av. Brasil, 442	Campinas	SP	04876-786	Brazil	GOURL	31	6	\N	\N
10424	1997-01-23	1997-02-20	1997-01-27	2	370.61	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	7	\N	\N
10425	1997-01-24	1997-02-21	1997-02-14	2	7.93	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	6	\N	\N
10426	1997-01-27	1997-02-24	1997-02-06	1	18.69	Galería del gastronómo	Rambla de Cataluña, 23	Barcelona	\N	8022	Spain	GALED	29	4	\N	\N
10427	1997-01-27	1997-02-24	1997-03-03	2	31.29	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria	PICCO	59	4	\N	\N
10428	1997-01-28	1997-02-25	1997-02-04	1	11.09	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	REGGC	66	7	\N	\N
10429	1997-01-29	1997-03-12	1997-02-07	2	56.63	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	3	\N	\N
10430	1997-01-30	1997-02-13	1997-02-03	1	458.78	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	4	\N	\N
10431	1997-01-30	1997-02-13	1997-02-07	2	44.17	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	4	\N	\N
10432	1997-01-31	1997-02-14	1997-02-07	2	4.34	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA	SPLIR	75	3	\N	\N
10433	1997-02-03	1997-03-03	1997-03-04	3	73.83	Princesa Isabel Vinhos	Estrada da saúde n. 58	Lisboa	\N	1756	Portugal	PRINI	60	3	\N	\N
10434	1997-02-03	1997-03-03	1997-02-13	2	17.92	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	3	\N	\N
10435	1997-02-04	1997-03-18	1997-02-07	2	9.21	Consolidated Holdings	Berkeley Gardens 12  Brewery	London	\N	WX1 6LT	UK	CONSH	16	8	\N	\N
10436	1997-02-05	1997-03-05	1997-02-11	2	156.66	Blondel père et fils	24, place Kléber	Strasbourg	\N	67000	France	BLONP	7	3	\N	\N
10437	1997-02-05	1997-03-05	1997-02-12	1	19.97	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	8	\N	\N
10438	1997-02-06	1997-03-06	1997-02-14	2	8.24	Toms Spezialitäten	Luisenstr. 48	Münster	\N	44087	Germany	TOMSP	79	3	\N	\N
10439	1997-02-07	1997-03-07	1997-02-10	3	4.07	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	6	\N	\N
10440	1997-02-10	1997-03-10	1997-02-28	2	86.53	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	4	\N	\N
10441	1997-02-10	1997-03-24	1997-03-14	2	73.02	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA	OLDWO	55	3	\N	\N
10442	1997-02-11	1997-03-11	1997-02-18	2	47.94	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	3	\N	\N
10443	1997-02-12	1997-03-12	1997-02-14	1	13.95	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	REGGC	66	8	\N	\N
10444	1997-02-12	1997-03-12	1997-02-21	3	3.5	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	3	\N	\N
10445	1997-02-13	1997-03-13	1997-02-20	1	9.3	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	3	\N	\N
10446	1997-02-14	1997-03-14	1997-02-19	1	14.68	Toms Spezialitäten	Luisenstr. 48	Münster	\N	44087	Germany	TOMSP	79	6	\N	\N
10447	1997-02-14	1997-03-14	1997-03-07	2	68.66	Ricardo Adocicados	Av. Copacabana, 267	Rio de Janeiro	RJ	02389-890	Brazil	RICAR	67	4	\N	\N
10448	1997-02-17	1997-03-17	1997-02-24	2	38.82	Rancho grande	Av. del Libertador 900	Buenos Aires	\N	1010	Argentina	RANCH	64	4	\N	\N
10449	1997-02-18	1997-03-18	1997-02-27	2	53.3	Blondel père et fils	24, place Kléber	Strasbourg	\N	67000	France	BLONP	7	3	\N	\N
10450	1997-02-19	1997-03-19	1997-03-11	2	7.23	Victuailles en stock	2, rue du Commerce	Lyon	\N	69004	France	VICTE	84	8	\N	\N
10451	1997-02-19	1997-03-05	1997-03-12	3	189.09	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	4	\N	\N
10452	1997-02-20	1997-03-20	1997-02-26	1	140.26	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	8	\N	\N
10453	1997-02-21	1997-03-21	1997-02-26	2	25.36	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	1	\N	\N
10454	1997-02-21	1997-03-21	1997-02-25	3	2.74	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	4	\N	\N
10455	1997-02-24	1997-04-07	1997-03-03	2	180.45	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	8	\N	\N
10456	1997-02-25	1997-04-08	1997-02-28	2	8.12	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	8	\N	\N
10457	1997-02-25	1997-03-25	1997-03-03	1	11.57	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	2	\N	\N
10458	1997-02-26	1997-03-26	1997-03-04	3	147.06	Suprêmes délices	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	SUPRD	76	7	\N	\N
10459	1997-02-27	1997-03-27	1997-02-28	2	25.09	Victuailles en stock	2, rue du Commerce	Lyon	\N	69004	France	VICTE	84	4	\N	\N
10460	1997-02-28	1997-03-28	1997-03-03	1	16.27	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	8	\N	\N
10461	1997-02-28	1997-03-28	1997-03-05	3	148.61	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	1	\N	\N
10462	1997-03-03	1997-03-31	1997-03-18	1	6.17	Consolidated Holdings	Berkeley Gardens 12  Brewery	London	\N	WX1 6LT	UK	CONSH	16	2	\N	\N
10463	1997-03-04	1997-04-01	1997-03-06	3	14.78	Suprêmes délices	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	SUPRD	76	5	\N	\N
10464	1997-03-04	1997-04-01	1997-03-14	2	89	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal	FURIB	28	4	\N	\N
10465	1997-03-05	1997-04-02	1997-03-14	3	145.04	Vaffeljernet	Smagsloget 45	Århus	\N	8200	Denmark	VAFFE	83	1	\N	\N
10466	1997-03-06	1997-04-03	1997-03-13	1	11.93	Comércio Mineiro	Av. dos Lusíadas, 23	Sao Paulo	SP	05432-043	Brazil	COMMI	15	4	\N	\N
10467	1997-03-06	1997-04-03	1997-03-11	2	4.93	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy	MAGAA	49	8	\N	\N
10468	1997-03-07	1997-04-04	1997-03-12	3	44.12	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	3	\N	\N
10469	1997-03-10	1997-04-07	1997-03-14	1	60.18	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	1	\N	\N
10470	1997-03-11	1997-04-08	1997-03-14	2	64.56	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	4	\N	\N
10471	1997-03-11	1997-04-08	1997-03-18	3	45.59	B-s Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK	BSBEV	11	2	\N	\N
10472	1997-03-12	1997-04-09	1997-03-19	1	4.2	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK	SEVES	72	8	\N	\N
10473	1997-03-13	1997-03-27	1997-03-21	3	16.37	Island Trading	Garden House Crowther Way	Cowes	Isle of Wight	PO31 7PJ	UK	ISLAT	38	1	\N	\N
10474	1997-03-13	1997-04-10	1997-03-21	2	83.49	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	México D.F.	\N	5033	Mexico	PERIC	58	5	\N	\N
10475	1997-03-14	1997-04-11	1997-04-04	1	68.52	Suprêmes délices	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	SUPRD	76	9	\N	\N
10476	1997-03-17	1997-04-14	1997-03-24	3	4.41	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	8	\N	\N
10477	1997-03-17	1997-04-14	1997-03-25	2	13.02	Princesa Isabel Vinhos	Estrada da saúde n. 58	Lisboa	\N	1756	Portugal	PRINI	60	5	\N	\N
10478	1997-03-18	1997-04-01	1997-03-26	3	4.81	Victuailles en stock	2, rue du Commerce	Lyon	\N	69004	France	VICTE	84	2	\N	\N
10479	1997-03-19	1997-04-16	1997-03-21	3	708.95	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	3	\N	\N
10480	1997-03-20	1997-04-17	1997-03-24	2	1.35	Folies gourmandes	184, chaussée de Tournai	Lille	\N	59000	France	FOLIG	23	6	\N	\N
10481	1997-03-20	1997-04-17	1997-03-25	2	64.33	Ricardo Adocicados	Av. Copacabana, 267	Rio de Janeiro	RJ	02389-890	Brazil	RICAR	67	8	\N	\N
10482	1997-03-21	1997-04-18	1997-04-10	3	7.48	Lazy K Kountry Store	12 Orchestra Terrace	Walla Walla	WA	99362	USA	LAZYK	43	1	\N	\N
10483	1997-03-24	1997-04-21	1997-04-25	2	15.28	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	7	\N	\N
10484	1997-03-24	1997-04-21	1997-04-01	3	6.88	B-s Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK	BSBEV	11	3	\N	\N
10485	1997-03-25	1997-04-08	1997-03-31	2	64.45	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	LINOD	47	4	\N	\N
10486	1997-03-26	1997-04-23	1997-04-02	2	30.53	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	1	\N	\N
10487	1997-03-26	1997-04-23	1997-03-28	2	71.07	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	2	\N	\N
10488	1997-03-27	1997-04-24	1997-04-02	2	4.93	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	8	\N	\N
10489	1997-03-28	1997-04-25	1997-04-09	2	5.29	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria	PICCO	59	6	\N	\N
10490	1997-03-31	1997-04-28	1997-04-03	2	210.19	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	7	\N	\N
10491	1997-03-31	1997-04-28	1997-04-08	3	16.96	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal	FURIB	28	8	\N	\N
10492	1997-04-01	1997-04-29	1997-04-11	1	62.89	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	3	\N	\N
10493	1997-04-02	1997-04-30	1997-04-10	3	10.64	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	4	\N	\N
10494	1997-04-02	1997-04-30	1997-04-09	2	65.99	Comércio Mineiro	Av. dos Lusíadas, 23	Sao Paulo	SP	05432-043	Brazil	COMMI	15	4	\N	\N
10495	1997-04-03	1997-05-01	1997-04-11	3	4.65	Laughing Bacchus Wine Cellars	2319 Elm St.	Vancouver	BC	V3F 2K1	Canada	LAUGB	42	3	\N	\N
10496	1997-04-04	1997-05-02	1997-04-07	2	46.77	Tradiçao Hipermercados	Av. Inês de Castro, 414	Sao Paulo	SP	05634-030	Brazil	TRADH	81	7	\N	\N
10497	1997-04-04	1997-05-02	1997-04-07	1	36.21	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	7	\N	\N
10498	1997-04-07	1997-05-05	1997-04-11	2	29.75	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	8	\N	\N
10499	1997-04-08	1997-05-06	1997-04-16	2	102.02	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	4	\N	\N
10500	1997-04-09	1997-05-07	1997-04-17	1	42.68	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	6	\N	\N
10501	1997-04-09	1997-05-07	1997-04-16	3	8.85	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany	BLAUS	6	9	\N	\N
10502	1997-04-10	1997-05-08	1997-04-29	1	69.32	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	México D.F.	\N	5033	Mexico	PERIC	58	2	\N	\N
10503	1997-04-11	1997-05-09	1997-04-16	2	16.74	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	6	\N	\N
10504	1997-04-11	1997-05-09	1997-04-18	3	59.13	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	4	\N	\N
10505	1997-04-14	1997-05-12	1997-04-21	3	7.13	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	3	\N	\N
10506	1997-04-15	1997-05-13	1997-05-02	2	21.19	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	9	\N	\N
10507	1997-04-15	1997-05-13	1997-04-22	1	47.45	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico	ANTON	3	7	\N	\N
10508	1997-04-16	1997-05-14	1997-05-13	2	4.99	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany	OTTIK	56	1	\N	\N
10509	1997-04-17	1997-05-15	1997-04-29	1	0.15	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany	BLAUS	6	4	\N	\N
10510	1997-04-18	1997-05-16	1997-04-28	3	367.63	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	6	\N	\N
10511	1997-04-18	1997-05-16	1997-04-21	3	350.64	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	4	\N	\N
10512	1997-04-21	1997-05-19	1997-04-24	2	3.53	Familia Arquibaldo	Rua Orós, 92	Sao Paulo	SP	05442-030	Brazil	FAMIA	21	7	\N	\N
10513	1997-04-22	1997-06-03	1997-04-28	1	105.65	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany	WANDK	86	7	\N	\N
10514	1997-04-22	1997-05-20	1997-05-16	2	789.95	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	3	\N	\N
10515	1997-04-23	1997-05-07	1997-05-23	1	204.47	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	2	\N	\N
10516	1997-04-24	1997-05-22	1997-05-01	3	62.78	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	2	\N	\N
10517	1997-04-24	1997-05-22	1997-04-29	3	32.07	North/South	South House 300 Queensbridge	London	\N	SW7 1RZ	UK	NORTS	53	3	\N	\N
10518	1997-04-25	1997-05-09	1997-05-05	2	218.15	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico	TORTU	80	4	\N	\N
10519	1997-04-28	1997-05-26	1997-05-01	3	91.76	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland	CHOPS	14	6	\N	\N
10520	1997-04-29	1997-05-27	1997-05-01	1	13.37	Santé Gourmet	Erling Skakkes gate 78	Stavern	\N	4110	Norway	SANTG	70	7	\N	\N
10521	1997-04-29	1997-05-27	1997-05-02	2	17.22	Cactus Comidas para llevar	Cerrito 333	Buenos Aires	\N	1010	Argentina	CACTU	12	8	\N	\N
10522	1997-04-30	1997-05-28	1997-05-06	1	45.33	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	4	\N	\N
10523	1997-05-01	1997-05-29	1997-05-30	2	77.63	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK	SEVES	72	7	\N	\N
10524	1997-05-01	1997-05-29	1997-05-07	2	244.79	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	1	\N	\N
10525	1997-05-02	1997-05-30	1997-05-23	2	11.06	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	1	\N	\N
10526	1997-05-05	1997-06-02	1997-05-15	2	58.59	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	4	\N	\N
10527	1997-05-05	1997-06-02	1997-05-07	1	41.9	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	7	\N	\N
10528	1997-05-06	1997-05-20	1997-05-09	2	3.35	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA	GREAL	32	6	\N	\N
10529	1997-05-07	1997-06-04	1997-05-09	2	66.69	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium	MAISD	50	5	\N	\N
10530	1997-05-08	1997-06-05	1997-05-12	2	339.22	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria	PICCO	59	3	\N	\N
10531	1997-05-08	1997-06-05	1997-05-19	1	8.12	Océano Atlántico Ltda.	Ing. Gustavo Moncada 8585 Piso 20-A	Buenos Aires	\N	1010	Argentina	OCEAN	54	7	\N	\N
10532	1997-05-09	1997-06-06	1997-05-12	3	74.46	Eastern Connection	35 King George	London	\N	WX3 6FW	UK	EASTC	19	7	\N	\N
10533	1997-05-12	1997-06-09	1997-05-22	1	188.04	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	8	\N	\N
10534	1997-05-12	1997-06-09	1997-05-14	2	27.94	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	8	\N	\N
10535	1997-05-13	1997-06-10	1997-05-21	1	15.64	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico	ANTON	3	4	\N	\N
10536	1997-05-14	1997-06-11	1997-06-06	2	58.88	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	3	\N	\N
10537	1997-05-14	1997-05-28	1997-05-19	1	78.85	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland	RICSU	68	1	\N	\N
10538	1997-05-15	1997-06-12	1997-05-16	3	4.87	B-s Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK	BSBEV	11	9	\N	\N
10539	1997-05-16	1997-06-13	1997-05-23	3	12.36	B-s Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK	BSBEV	11	6	\N	\N
10540	1997-05-19	1997-06-16	1997-06-13	3	1007.64	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	3	\N	\N
10541	1997-05-19	1997-06-16	1997-05-29	1	68.65	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	2	\N	\N
10542	1997-05-20	1997-06-17	1997-05-26	3	10.95	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	1	\N	\N
10543	1997-05-21	1997-06-18	1997-05-23	2	48.17	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	8	\N	\N
10544	1997-05-21	1997-06-18	1997-05-30	1	24.91	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA	LONEP	48	4	\N	\N
10545	1997-05-22	1997-06-19	1997-06-26	2	11.92	Lazy K Kountry Store	12 Orchestra Terrace	Walla Walla	WA	99362	USA	LAZYK	43	8	\N	\N
10546	1997-05-23	1997-06-20	1997-05-27	3	194.72	Victuailles en stock	2, rue du Commerce	Lyon	\N	69004	France	VICTE	84	1	\N	\N
10547	1997-05-23	1997-06-20	1997-06-02	2	178.43	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK	SEVES	72	3	\N	\N
10548	1997-05-26	1997-06-23	1997-06-02	2	1.43	Toms Spezialitäten	Luisenstr. 48	Münster	\N	44087	Germany	TOMSP	79	3	\N	\N
10549	1997-05-27	1997-06-10	1997-05-30	1	171.24	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	5	\N	\N
10550	1997-05-28	1997-06-25	1997-06-06	3	4.32	Godos Cocina Típica	C/ Romero, 33	Sevilla	\N	41101	Spain	GODOS	30	7	\N	\N
10551	1997-05-28	1997-07-09	1997-06-06	3	72.95	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal	FURIB	28	4	\N	\N
10552	1997-05-29	1997-06-26	1997-06-05	1	83.22	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	2	\N	\N
10553	1997-05-30	1997-06-27	1997-06-03	2	149.49	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	2	\N	\N
10554	1997-05-30	1997-06-27	1997-06-05	3	120.97	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany	OTTIK	56	4	\N	\N
10555	1997-06-02	1997-06-30	1997-06-04	3	252.49	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	6	\N	\N
10556	1997-06-03	1997-07-15	1997-06-13	1	9.8	Simons bistro	Vinbæltet 34	Kobenhavn	\N	1734	Denmark	SIMOB	73	2	\N	\N
10557	1997-06-03	1997-06-17	1997-06-06	2	96.72	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	9	\N	\N
10558	1997-06-04	1997-07-02	1997-06-10	2	72.97	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	1	\N	\N
10559	1997-06-05	1997-07-03	1997-06-13	1	8.05	Blondel père et fils	24, place Kléber	Strasbourg	\N	67000	France	BLONP	7	6	\N	\N
10560	1997-06-06	1997-07-04	1997-06-09	1	36.65	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	8	\N	\N
10561	1997-06-06	1997-07-04	1997-06-09	2	242.21	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	2	\N	\N
10562	1997-06-09	1997-07-07	1997-06-12	1	22.95	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	REGGC	66	1	\N	\N
10563	1997-06-10	1997-07-22	1997-06-24	2	60.43	Ricardo Adocicados	Av. Copacabana, 267	Rio de Janeiro	RJ	02389-890	Brazil	RICAR	67	2	\N	\N
10564	1997-06-10	1997-07-08	1997-06-16	3	13.75	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	4	\N	\N
10565	1997-06-11	1997-07-09	1997-06-18	2	7.15	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	8	\N	\N
10566	1997-06-12	1997-07-10	1997-06-18	1	88.4	Blondel père et fils	24, place Kléber	Strasbourg	\N	67000	France	BLONP	7	9	\N	\N
10567	1997-06-12	1997-07-10	1997-06-17	1	33.97	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	1	\N	\N
10568	1997-06-13	1997-07-11	1997-07-09	3	6.54	Galería del gastronómo	Rambla de Cataluña, 23	Barcelona	\N	8022	Spain	GALED	29	3	\N	\N
10569	1997-06-16	1997-07-14	1997-07-11	1	58.98	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	5	\N	\N
10570	1997-06-17	1997-07-15	1997-06-19	3	188.99	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	3	\N	\N
10571	1997-06-17	1997-07-29	1997-07-04	3	26.06	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	8	\N	\N
10572	1997-06-18	1997-07-16	1997-06-25	2	116.43	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	3	\N	\N
10573	1997-06-19	1997-07-17	1997-06-20	3	84.84	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico	ANTON	3	7	\N	\N
10574	1997-06-19	1997-07-17	1997-06-30	2	37.6	Trail-s Head Gourmet Provisioners	722 DaVinci Blvd.	Kirkland	WA	98034	USA	TRAIH	82	4	\N	\N
10575	1997-06-20	1997-07-04	1997-06-30	1	127.34	Morgenstern Gesundkost	Heerstr. 22	Leipzig	\N	4179	Germany	MORGK	52	5	\N	\N
10576	1997-06-23	1997-07-07	1997-06-30	3	18.56	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico	TORTU	80	3	\N	\N
10577	1997-06-23	1997-08-04	1997-06-30	2	25.41	Trail-s Head Gourmet Provisioners	722 DaVinci Blvd.	Kirkland	WA	98034	USA	TRAIH	82	9	\N	\N
10578	1997-06-24	1997-07-22	1997-07-25	3	29.6	B-s Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK	BSBEV	11	4	\N	\N
10579	1997-06-25	1997-07-23	1997-07-04	2	13.73	Let-s Stop N Shop	87 Polk St. Suite 5	San Francisco	CA	94117	USA	LETSS	45	1	\N	\N
10580	1997-06-26	1997-07-24	1997-07-01	3	75.89	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany	OTTIK	56	4	\N	\N
10581	1997-06-26	1997-07-24	1997-07-02	1	3.01	Familia Arquibaldo	Rua Orós, 92	Sao Paulo	SP	05442-030	Brazil	FAMIA	21	3	\N	\N
10582	1997-06-27	1997-07-25	1997-07-14	2	27.71	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany	BLAUS	6	3	\N	\N
10583	1997-06-30	1997-07-28	1997-07-04	2	7.28	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	2	\N	\N
10584	1997-06-30	1997-07-28	1997-07-04	1	59.14	Blondel père et fils	24, place Kléber	Strasbourg	\N	67000	France	BLONP	7	4	\N	\N
10585	1997-07-01	1997-07-29	1997-07-10	1	13.41	Wellington Importadora	Rua do Mercado, 12	Resende	SP	08737-363	Brazil	WELLI	88	7	\N	\N
10586	1997-07-02	1997-07-30	1997-07-09	1	0.48	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	REGGC	66	9	\N	\N
10587	1997-07-02	1997-07-30	1997-07-09	1	62.52	Que Delícia	Rua da Panificadora, 12	Rio de Janeiro	RJ	02389-673	Brazil	QUEDE	61	1	\N	\N
10588	1997-07-03	1997-07-31	1997-07-10	3	194.67	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	2	\N	\N
10589	1997-07-04	1997-08-01	1997-07-14	2	4.42	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA	GREAL	32	8	\N	\N
10590	1997-07-07	1997-08-04	1997-07-14	3	44.77	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	4	\N	\N
10591	1997-07-07	1997-07-21	1997-07-16	1	55.92	Vaffeljernet	Smagsloget 45	Århus	\N	8200	Denmark	VAFFE	83	1	\N	\N
10592	1997-07-08	1997-08-05	1997-07-16	1	32.1	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	3	\N	\N
10593	1997-07-09	1997-08-06	1997-08-13	2	174.2	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	7	\N	\N
10594	1997-07-09	1997-08-06	1997-07-16	2	5.24	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA	OLDWO	55	3	\N	\N
10595	1997-07-10	1997-08-07	1997-07-14	1	96.78	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	2	\N	\N
10596	1997-07-11	1997-08-08	1997-08-12	1	16.34	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	8	\N	\N
10597	1997-07-11	1997-08-08	1997-07-18	3	35.12	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria	PICCO	59	7	\N	\N
10598	1997-07-14	1997-08-11	1997-07-18	3	44.42	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	1	\N	\N
10599	1997-07-15	1997-08-26	1997-07-21	3	29.98	B-s Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK	BSBEV	11	6	\N	\N
10600	1997-07-16	1997-08-13	1997-07-21	1	45.13	Hungry Coyote Import Store	City Center Plaza 516 Main St.	Elgin	OR	97827	USA	HUNGC	36	4	\N	\N
10601	1997-07-16	1997-08-27	1997-07-22	1	58.3	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	7	\N	\N
10602	1997-07-17	1997-08-14	1997-07-22	2	2.92	Vaffeljernet	Smagsloget 45	Århus	\N	8200	Denmark	VAFFE	83	8	\N	\N
10603	1997-07-18	1997-08-15	1997-08-08	2	48.77	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	8	\N	\N
10604	1997-07-18	1997-08-15	1997-07-29	1	7.46	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal	FURIB	28	1	\N	\N
10605	1997-07-21	1997-08-18	1997-07-29	2	379.13	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	1	\N	\N
10606	1997-07-22	1997-08-19	1997-07-31	3	79.4	Tradiçao Hipermercados	Av. Inês de Castro, 414	Sao Paulo	SP	05634-030	Brazil	TRADH	81	4	\N	\N
10607	1997-07-22	1997-08-19	1997-07-25	1	200.24	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	5	\N	\N
10608	1997-07-23	1997-08-20	1997-08-01	2	27.79	Toms Spezialitäten	Luisenstr. 48	Münster	\N	44087	Germany	TOMSP	79	4	\N	\N
10609	1997-07-24	1997-08-21	1997-07-30	2	1.85	Du monde entier	67, rue des Cinquante Otages	Nantes	\N	44000	France	DUMON	18	7	\N	\N
10610	1997-07-25	1997-08-22	1997-08-06	1	26.78	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	8	\N	\N
10611	1997-07-25	1997-08-22	1997-08-01	2	80.65	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland	WOLZA	91	6	\N	\N
10612	1997-07-28	1997-08-25	1997-08-01	2	544.08	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	1	\N	\N
10613	1997-07-29	1997-08-26	1997-08-01	2	8.11	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	4	\N	\N
10614	1997-07-29	1997-08-26	1997-08-01	3	1.93	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany	BLAUS	6	8	\N	\N
10615	1997-07-30	1997-08-27	1997-08-06	3	0.75	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland	WILMK	90	2	\N	\N
10616	1997-07-31	1997-08-28	1997-08-05	2	116.53	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA	GREAL	32	1	\N	\N
10617	1997-07-31	1997-08-28	1997-08-04	2	18.53	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA	GREAL	32	4	\N	\N
10618	1997-08-01	1997-09-12	1997-08-08	1	154.68	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	1	\N	\N
10619	1997-08-04	1997-09-01	1997-08-07	3	91.05	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	3	\N	\N
10620	1997-08-05	1997-09-02	1997-08-14	3	0.94	Laughing Bacchus Wine Cellars	2319 Elm St.	Vancouver	BC	V3F 2K1	Canada	LAUGB	42	2	\N	\N
10621	1997-08-05	1997-09-02	1997-08-11	2	23.73	Island Trading	Garden House Crowther Way	Cowes	Isle of Wight	PO31 7PJ	UK	ISLAT	38	4	\N	\N
10622	1997-08-06	1997-09-03	1997-08-11	3	50.97	Ricardo Adocicados	Av. Copacabana, 267	Rio de Janeiro	RJ	02389-890	Brazil	RICAR	67	4	\N	\N
10623	1997-08-07	1997-09-04	1997-08-12	2	97.18	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	8	\N	\N
10624	1997-08-07	1997-09-04	1997-08-19	2	94.8	The Cracker Box	55 Grizzly Peak Rd.	Butte	MT	59801	USA	THECR	78	4	\N	\N
10625	1997-08-08	1997-09-05	1997-08-14	1	43.9	Ana Trujillo Emparedados y helados	Avda. de la Constitución 2222	México D.F.	\N	5021	Mexico	ANATR	2	3	\N	\N
10626	1997-08-11	1997-09-08	1997-08-20	2	138.69	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	1	\N	\N
10627	1997-08-11	1997-09-22	1997-08-21	3	107.46	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	8	\N	\N
10628	1997-08-12	1997-09-09	1997-08-20	3	30.36	Blondel père et fils	24, place Kléber	Strasbourg	\N	67000	France	BLONP	7	4	\N	\N
10629	1997-08-12	1997-09-09	1997-08-20	3	85.46	Godos Cocina Típica	C/ Romero, 33	Sevilla	\N	41101	Spain	GODOS	30	4	\N	\N
10630	1997-08-13	1997-09-10	1997-08-19	2	32.35	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	1	\N	\N
10631	1997-08-14	1997-09-11	1997-08-15	1	0.87	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	8	\N	\N
10632	1997-08-14	1997-09-11	1997-08-19	1	41.38	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany	WANDK	86	8	\N	\N
10633	1997-08-15	1997-09-12	1997-08-18	3	477.9	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	7	\N	\N
10634	1997-08-15	1997-09-12	1997-08-21	3	487.38	Folies gourmandes	184, chaussée de Tournai	Lille	\N	59000	France	FOLIG	23	4	\N	\N
10635	1997-08-18	1997-09-15	1997-08-21	3	47.46	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy	MAGAA	49	8	\N	\N
10636	1997-08-19	1997-09-16	1997-08-26	1	1.15	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	4	\N	\N
10637	1997-08-19	1997-09-16	1997-08-26	1	201.29	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	6	\N	\N
10638	1997-08-20	1997-09-17	1997-09-01	1	158.44	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	LINOD	47	3	\N	\N
10639	1997-08-20	1997-09-17	1997-08-27	3	38.64	Santé Gourmet	Erling Skakkes gate 78	Stavern	\N	4110	Norway	SANTG	70	7	\N	\N
10640	1997-08-21	1997-09-18	1997-08-28	1	23.55	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany	WANDK	86	4	\N	\N
10641	1997-08-22	1997-09-19	1997-08-26	2	179.61	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	4	\N	\N
10642	1997-08-22	1997-09-19	1997-09-05	3	41.89	Simons bistro	Vinbæltet 34	Kobenhavn	\N	1734	Denmark	SIMOB	73	7	\N	\N
10643	1997-08-25	1997-09-22	1997-09-02	1	29.46	Alfreds Futterkiste	Obere Str. 57	Berlin	\N	12209	Germany	ALFKI	1	6	\N	\N
10644	1997-08-25	1997-09-22	1997-09-01	2	0.14	Wellington Importadora	Rua do Mercado, 12	Resende	SP	08737-363	Brazil	WELLI	88	3	\N	\N
10645	1997-08-26	1997-09-23	1997-09-02	1	12.41	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	4	\N	\N
10646	1997-08-27	1997-10-08	1997-09-03	3	142.33	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	9	\N	\N
10647	1997-08-27	1997-09-10	1997-09-03	2	45.54	Que Delícia	Rua da Panificadora, 12	Rio de Janeiro	RJ	02389-673	Brazil	QUEDE	61	4	\N	\N
10648	1997-08-28	1997-10-09	1997-09-09	2	14.25	Ricardo Adocicados	Av. Copacabana, 267	Rio de Janeiro	RJ	02389-890	Brazil	RICAR	67	5	\N	\N
10649	1997-08-28	1997-09-25	1997-08-29	3	6.2	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium	MAISD	50	5	\N	\N
10650	1997-08-29	1997-09-26	1997-09-03	3	176.81	Familia Arquibaldo	Rua Orós, 92	Sao Paulo	SP	05442-030	Brazil	FAMIA	21	5	\N	\N
10651	1997-09-01	1997-09-29	1997-09-11	2	20.6	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany	WANDK	86	8	\N	\N
10652	1997-09-01	1997-09-29	1997-09-08	2	7.14	Gourmet Lanchonetes	Av. Brasil, 442	Campinas	SP	04876-786	Brazil	GOURL	31	4	\N	\N
10653	1997-09-02	1997-09-30	1997-09-19	1	93.25	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	1	\N	\N
10654	1997-09-02	1997-09-30	1997-09-11	1	55.26	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	5	\N	\N
10655	1997-09-03	1997-10-01	1997-09-11	2	4.41	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	REGGC	66	1	\N	\N
10656	1997-09-04	1997-10-02	1997-09-10	1	57.15	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA	GREAL	32	6	\N	\N
10657	1997-09-04	1997-10-02	1997-09-15	2	352.69	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	2	\N	\N
10658	1997-09-05	1997-10-03	1997-09-08	1	364.15	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	4	\N	\N
10659	1997-09-05	1997-10-03	1997-09-10	2	105.81	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	7	\N	\N
10660	1997-09-08	1997-10-06	1997-10-15	1	111.29	Hungry Coyote Import Store	City Center Plaza 516 Main St.	Elgin	OR	97827	USA	HUNGC	36	8	\N	\N
10661	1997-09-09	1997-10-07	1997-09-15	3	17.55	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	7	\N	\N
10662	1997-09-09	1997-10-07	1997-09-18	2	1.28	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA	LONEP	48	3	\N	\N
10663	1997-09-10	1997-09-24	1997-10-03	2	113.15	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	2	\N	\N
10664	1997-09-10	1997-10-08	1997-09-19	3	1.27	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal	FURIB	28	1	\N	\N
10665	1997-09-11	1997-10-09	1997-09-17	2	26.31	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA	LONEP	48	1	\N	\N
10666	1997-09-12	1997-10-10	1997-09-22	2	232.42	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland	RICSU	68	7	\N	\N
10667	1997-09-12	1997-10-10	1997-09-19	1	78.09	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	7	\N	\N
10668	1997-09-15	1997-10-13	1997-09-23	2	47.22	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany	WANDK	86	1	\N	\N
10669	1997-09-15	1997-10-13	1997-09-22	1	24.39	Simons bistro	Vinbæltet 34	Kobenhavn	\N	1734	Denmark	SIMOB	73	2	\N	\N
10670	1997-09-16	1997-10-14	1997-09-18	1	203.48	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	4	\N	\N
10671	1997-09-17	1997-10-15	1997-09-24	1	30.34	France restauration	54, rue Royale	Nantes	\N	44000	France	FRANR	26	1	\N	\N
10672	1997-09-17	1997-10-01	1997-09-26	2	95.75	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	9	\N	\N
10673	1997-09-18	1997-10-16	1997-09-19	1	22.76	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland	WILMK	90	2	\N	\N
10674	1997-09-18	1997-10-16	1997-09-30	2	0.9	Island Trading	Garden House Crowther Way	Cowes	Isle of Wight	PO31 7PJ	UK	ISLAT	38	4	\N	\N
10675	1997-09-19	1997-10-17	1997-09-23	2	31.85	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	5	\N	\N
10676	1997-09-22	1997-10-20	1997-09-29	2	2.01	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico	TORTU	80	2	\N	\N
10677	1997-09-22	1997-10-20	1997-09-26	3	4.03	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico	ANTON	3	1	\N	\N
10678	1997-09-23	1997-10-21	1997-10-16	3	388.98	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	7	\N	\N
10679	1997-09-23	1997-10-21	1997-09-30	3	27.94	Blondel père et fils	24, place Kléber	Strasbourg	\N	67000	France	BLONP	7	8	\N	\N
10680	1997-09-24	1997-10-22	1997-09-26	1	26.61	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA	OLDWO	55	1	\N	\N
10681	1997-09-25	1997-10-23	1997-09-30	3	76.13	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA	GREAL	32	3	\N	\N
10682	1997-09-25	1997-10-23	1997-10-01	2	36.13	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico	ANTON	3	3	\N	\N
10683	1997-09-26	1997-10-24	1997-10-01	1	4.4	Du monde entier	67, rue des Cinquante Otages	Nantes	\N	44000	France	DUMON	18	2	\N	\N
10684	1997-09-26	1997-10-24	1997-09-30	1	145.63	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany	OTTIK	56	3	\N	\N
10685	1997-09-29	1997-10-13	1997-10-03	2	33.75	Gourmet Lanchonetes	Av. Brasil, 442	Campinas	SP	04876-786	Brazil	GOURL	31	4	\N	\N
10686	1997-09-30	1997-10-28	1997-10-08	1	96.5	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria	PICCO	59	2	\N	\N
10687	1997-09-30	1997-10-28	1997-10-30	2	296.43	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	9	\N	\N
10688	1997-10-01	1997-10-15	1997-10-07	2	299.09	Vaffeljernet	Smagsloget 45	Århus	\N	8200	Denmark	VAFFE	83	4	\N	\N
10689	1997-10-01	1997-10-29	1997-10-07	2	13.42	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	1	\N	\N
10690	1997-10-02	1997-10-30	1997-10-03	1	15.8	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	1	\N	\N
10691	1997-10-03	1997-11-14	1997-10-22	2	810.05	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	2	\N	\N
10692	1997-10-03	1997-10-31	1997-10-13	2	61.02	Alfred-s Futterkiste	Obere Str. 57	Berlin	\N	12209	Germany	ALFKI	1	4	\N	\N
10693	1997-10-06	1997-10-20	1997-10-10	3	139.34	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	3	\N	\N
10694	1997-10-06	1997-11-03	1997-10-09	3	398.36	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	8	\N	\N
10695	1997-10-07	1997-11-18	1997-10-14	1	16.72	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland	WILMK	90	7	\N	\N
10696	1997-10-08	1997-11-19	1997-10-14	3	102.55	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	8	\N	\N
10697	1997-10-08	1997-11-05	1997-10-14	1	45.52	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	LINOD	47	3	\N	\N
10698	1997-10-09	1997-11-06	1997-10-17	1	272.47	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	4	\N	\N
10699	1997-10-09	1997-11-06	1997-10-13	3	0.58	Morgenstern Gesundkost	Heerstr. 22	Leipzig	\N	4179	Germany	MORGK	52	3	\N	\N
10700	1997-10-10	1997-11-07	1997-10-16	1	65.1	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	3	\N	\N
10701	1997-10-13	1997-10-27	1997-10-15	3	220.31	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	6	\N	\N
10702	1997-10-13	1997-11-24	1997-10-21	1	23.94	Alfred-s Futterkiste	Obere Str. 57	Berlin	\N	12209	Germany	ALFKI	1	4	\N	\N
10703	1997-10-14	1997-11-11	1997-10-20	2	152.3	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	6	\N	\N
10704	1997-10-14	1997-11-11	1997-11-07	1	4.78	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	6	\N	\N
10705	1997-10-15	1997-11-12	1997-11-18	2	3.52	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	9	\N	\N
10706	1997-10-16	1997-11-13	1997-10-21	3	135.63	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA	OLDWO	55	8	\N	\N
10707	1997-10-16	1997-10-30	1997-10-23	3	21.74	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	4	\N	\N
10708	1997-10-17	1997-11-28	1997-11-05	2	2.96	The Big Cheese	89 Jefferson Way Suite 2	Portland	OR	97201	USA	THEBI	77	6	\N	\N
10709	1997-10-17	1997-11-14	1997-11-20	3	210.8	Gourmet Lanchonetes	Av. Brasil, 442	Campinas	SP	04876-786	Brazil	GOURL	31	1	\N	\N
10710	1997-10-20	1997-11-17	1997-10-23	1	4.98	Franchi S.p.A.	Via Monte Bianco 34	Torino	\N	10100	Italy	FRANS	27	1	\N	\N
10711	1997-10-21	1997-12-02	1997-10-29	2	52.41	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	5	\N	\N
10712	1997-10-21	1997-11-18	1997-10-31	1	89.93	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	3	\N	\N
10713	1997-10-22	1997-11-19	1997-10-24	1	167.05	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	1	\N	\N
10714	1997-10-22	1997-11-19	1997-10-27	3	24.49	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	5	\N	\N
10715	1997-10-23	1997-11-06	1997-10-29	1	63.2	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	3	\N	\N
10716	1997-10-24	1997-11-21	1997-10-27	2	22.57	Rancho grande	Av. del Libertador 900	Buenos Aires	\N	1010	Argentina	RANCH	64	4	\N	\N
10717	1997-10-24	1997-11-21	1997-10-29	2	59.25	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	1	\N	\N
10718	1997-10-27	1997-11-24	1997-10-29	3	170.88	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	1	\N	\N
10719	1997-10-27	1997-11-24	1997-11-05	2	51.44	Let-s Stop N Shop	87 Polk St. Suite 5	San Francisco	CA	94117	USA	LETSS	45	8	\N	\N
10720	1997-10-28	1997-11-11	1997-11-05	2	9.53	Que Delícia	Rua da Panificadora, 12	Rio de Janeiro	RJ	02389-673	Brazil	QUEDE	61	8	\N	\N
10721	1997-10-29	1997-11-26	1997-10-31	3	48.92	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	5	\N	\N
10722	1997-10-29	1997-12-10	1997-11-04	1	74.58	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	8	\N	\N
10723	1997-10-30	1997-11-27	1997-11-25	1	21.72	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	3	\N	\N
10724	1997-10-30	1997-12-11	1997-11-05	2	57.75	Mère Paillarde	43 rue St. Laurent	Montréal	Québec	H1J 1C3	Canada	MEREP	51	8	\N	\N
10725	1997-10-31	1997-11-28	1997-11-05	3	10.83	Familia Arquibaldo	Rua Orós, 92	Sao Paulo	SP	05442-030	Brazil	FAMIA	21	4	\N	\N
10726	1997-11-03	1997-11-17	1997-12-05	1	16.56	Eastern Connection	35 King George	London	\N	WX3 6FW	UK	EASTC	19	4	\N	\N
10727	1997-11-03	1997-12-01	1997-12-05	1	89.9	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	REGGC	66	2	\N	\N
10728	1997-11-04	1997-12-02	1997-11-11	2	58.33	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	4	\N	\N
10729	1997-11-04	1997-12-16	1997-11-14	3	141.06	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	LINOD	47	8	\N	\N
10730	1997-11-05	1997-12-03	1997-11-14	1	20.12	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	5	\N	\N
10731	1997-11-06	1997-12-04	1997-11-14	1	96.65	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland	CHOPS	14	7	\N	\N
10732	1997-11-06	1997-12-04	1997-11-07	1	16.97	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	3	\N	\N
10733	1997-11-07	1997-12-05	1997-11-10	3	110.11	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	1	\N	\N
10734	1997-11-07	1997-12-05	1997-11-12	3	1.63	Gourmet Lanchonetes	Av. Brasil, 442	Campinas	SP	04876-786	Brazil	GOURL	31	2	\N	\N
10735	1997-11-10	1997-12-08	1997-11-21	2	45.97	Let-s Stop N Shop	87 Polk St. Suite 5	San Francisco	CA	94117	USA	LETSS	45	6	\N	\N
10736	1997-11-11	1997-12-09	1997-11-21	2	44.1	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	9	\N	\N
10737	1997-11-11	1997-12-09	1997-11-18	2	7.79	Vins et alcools Chevalier	59 rue de l-Abbaye	Reims	\N	51100	France	VINET	85	2	\N	\N
10738	1997-11-12	1997-12-10	1997-11-18	1	2.91	Spécialités du monde	25, rue Lauriston	Paris	\N	75016	France	SPECD	74	2	\N	\N
10739	1997-11-12	1997-12-10	1997-11-17	3	11.08	Vins et alcools Chevalier	59 rue de l-Abbaye	Reims	\N	51100	France	VINET	85	3	\N	\N
10740	1997-11-13	1997-12-11	1997-11-25	2	81.88	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	4	\N	\N
10741	1997-11-14	1997-11-28	1997-11-18	3	10.96	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	4	\N	\N
10742	1997-11-14	1997-12-12	1997-11-18	3	243.73	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	3	\N	\N
10743	1997-11-17	1997-12-15	1997-11-21	2	23.72	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	1	\N	\N
10744	1997-11-17	1997-12-15	1997-11-24	1	69.19	Vaffeljernet	Smagsloget 45	Århus	\N	8200	Denmark	VAFFE	83	6	\N	\N
10745	1997-11-18	1997-12-16	1997-11-27	1	3.52	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	9	\N	\N
10746	1997-11-19	1997-12-17	1997-11-21	3	31.43	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland	CHOPS	14	1	\N	\N
10747	1997-11-19	1997-12-17	1997-11-26	1	117.33	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria	PICCO	59	6	\N	\N
10748	1997-11-20	1997-12-18	1997-11-28	1	232.55	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	3	\N	\N
10749	1997-11-20	1997-12-18	1997-12-19	2	61.53	Island Trading	Garden House Crowther Way	Cowes	Isle of Wight	PO31 7PJ	UK	ISLAT	38	4	\N	\N
10750	1997-11-21	1997-12-19	1997-11-24	1	79.3	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	9	\N	\N
10751	1997-11-24	1997-12-22	1997-12-03	3	130.79	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland	RICSU	68	3	\N	\N
10752	1997-11-24	1997-12-22	1997-11-28	3	1.39	North/South	South House 300 Queensbridge	London	\N	SW7 1RZ	UK	NORTS	53	2	\N	\N
10753	1997-11-25	1997-12-23	1997-11-27	1	7.7	Franchi S.p.A.	Via Monte Bianco 34	Torino	\N	10100	Italy	FRANS	27	3	\N	\N
10754	1997-11-25	1997-12-23	1997-11-27	3	2.38	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy	MAGAA	49	6	\N	\N
10755	1997-11-26	1997-12-24	1997-11-28	2	16.71	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	4	\N	\N
10756	1997-11-27	1997-12-25	1997-12-02	2	73.21	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA	SPLIR	75	8	\N	\N
10757	1997-11-27	1997-12-25	1997-12-15	1	8.19	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	6	\N	\N
10758	1997-11-28	1997-12-26	1997-12-04	3	138.17	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland	RICSU	68	3	\N	\N
10759	1997-11-28	1997-12-26	1997-12-12	3	11.99	Ana Trujillo Emparedados y helados	Avda. de la Constitución 2222	México D.F.	\N	5021	Mexico	ANATR	2	3	\N	\N
10760	1997-12-01	1997-12-29	1997-12-10	1	155.64	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium	MAISD	50	4	\N	\N
10761	1997-12-02	1997-12-30	1997-12-08	2	18.66	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	5	\N	\N
10762	1997-12-02	1997-12-30	1997-12-09	1	328.74	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	3	\N	\N
10763	1997-12-03	1997-12-31	1997-12-08	3	37.35	Folies gourmandes	184, chaussée de Tournai	Lille	\N	59000	France	FOLIG	23	3	\N	\N
10764	1997-12-03	1997-12-31	1997-12-08	3	145.45	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	6	\N	\N
10765	1997-12-04	1998-01-01	1997-12-09	3	42.74	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	3	\N	\N
10766	1997-12-05	1998-01-02	1997-12-09	1	157.55	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany	OTTIK	56	4	\N	\N
10767	1997-12-05	1998-01-02	1997-12-15	3	1.59	Suprêmes délices	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	SUPRD	76	4	\N	\N
10768	1997-12-08	1998-01-05	1997-12-15	2	146.32	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	3	\N	\N
10769	1997-12-08	1998-01-05	1997-12-12	1	65.06	Vaffeljernet	Smagsloget 45	Århus	\N	8200	Denmark	VAFFE	83	3	\N	\N
10770	1997-12-09	1998-01-06	1997-12-17	3	5.32	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	8	\N	\N
10771	1997-12-10	1998-01-07	1998-01-02	2	11.19	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	9	\N	\N
10772	1997-12-10	1998-01-07	1997-12-19	2	91.28	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	3	\N	\N
10773	1997-12-11	1998-01-08	1997-12-16	3	96.43	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	1	\N	\N
10774	1997-12-11	1997-12-25	1997-12-12	1	48.2	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	4	\N	\N
10775	1997-12-12	1998-01-09	1997-12-26	1	20.25	The Cracker Box	55 Grizzly Peak Rd.	Butte	MT	59801	USA	THECR	78	7	\N	\N
10776	1997-12-15	1998-01-12	1997-12-18	3	351.53	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	1	\N	\N
10777	1997-12-15	1997-12-29	1998-01-21	2	3.01	Gourmet Lanchonetes	Av. Brasil, 442	Campinas	SP	04876-786	Brazil	GOURL	31	7	\N	\N
10778	1997-12-16	1998-01-13	1997-12-24	1	6.79	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	3	\N	\N
10779	1997-12-16	1998-01-13	1998-01-14	2	58.13	Morgenstern Gesundkost	Heerstr. 22	Leipzig	\N	4179	Germany	MORGK	52	3	\N	\N
10780	1997-12-16	1997-12-30	1997-12-25	1	42.13	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	2	\N	\N
10781	1997-12-17	1998-01-14	1997-12-19	3	73.16	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	2	\N	\N
10782	1997-12-17	1998-01-14	1997-12-22	3	1.1	Cactus Comidas para llevar	Cerrito 333	Buenos Aires	\N	1010	Argentina	CACTU	12	9	\N	\N
10783	1997-12-18	1998-01-15	1997-12-19	2	124.98	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	4	\N	\N
10784	1997-12-18	1998-01-15	1997-12-22	3	70.09	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy	MAGAA	49	4	\N	\N
10785	1997-12-18	1998-01-15	1997-12-24	3	1.51	GROSELLA-Restaurante	5ª Ave. Los Palos Grandes	Caracas	DF	1081	Venezuela	GROSR	33	1	\N	\N
10786	1997-12-19	1998-01-16	1997-12-23	1	110.87	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	8	\N	\N
10787	1997-12-19	1998-01-02	1997-12-26	1	249.93	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	2	\N	\N
10788	1997-12-22	1998-01-19	1998-01-19	2	42.7	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	1	\N	\N
10789	1997-12-22	1998-01-19	1997-12-31	2	100.6	Folies gourmandes	184, chaussée de Tournai	Lille	\N	59000	France	FOLIG	23	1	\N	\N
10790	1997-12-22	1998-01-19	1997-12-26	1	28.23	Gourmet Lanchonetes	Av. Brasil, 442	Campinas	SP	04876-786	Brazil	GOURL	31	6	\N	\N
10791	1997-12-23	1998-01-20	1998-01-01	2	16.85	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	6	\N	\N
10792	1997-12-23	1998-01-20	1997-12-31	3	23.79	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland	WOLZA	91	1	\N	\N
10793	1997-12-24	1998-01-21	1998-01-08	3	4.52	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	3	\N	\N
10794	1997-12-24	1998-01-21	1998-01-02	1	21.49	Que Delícia	Rua da Panificadora, 12	Rio de Janeiro	RJ	02389-673	Brazil	QUEDE	61	6	\N	\N
10795	1997-12-24	1998-01-21	1998-01-20	2	126.66	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	8	\N	\N
10796	1997-12-25	1998-01-22	1998-01-14	1	26.52	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	3	\N	\N
10797	1997-12-25	1998-01-22	1998-01-05	2	33.35	Drachenblut Delikatessen	Walserweg 21	Aachen	\N	52066	Germany	DRACD	17	7	\N	\N
10798	1997-12-26	1998-01-23	1998-01-05	1	2.33	Island Trading	Garden House Crowther Way	Cowes	Isle of Wight	PO31 7PJ	UK	ISLAT	38	2	\N	\N
10799	1997-12-26	1998-02-06	1998-01-05	3	30.76	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	9	\N	\N
10800	1997-12-26	1998-01-23	1998-01-05	3	137.44	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK	SEVES	72	1	\N	\N
10801	1997-12-29	1998-01-26	1997-12-31	2	97.09	Bólido Comidas preparadas	C/ Araquil, 67	Madrid	\N	28023	Spain	BOLID	8	4	\N	\N
10802	1997-12-29	1998-01-26	1998-01-02	2	257.26	Simons bistro	Vinbæltet 34	Kobenhavn	\N	1734	Denmark	SIMOB	73	4	\N	\N
10803	1997-12-30	1998-01-27	1998-01-06	1	55.23	Wellington Importadora	Rua do Mercado, 12	Resende	SP	08737-363	Brazil	WELLI	88	4	\N	\N
10804	1997-12-30	1998-01-27	1998-01-07	2	27.33	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK	SEVES	72	6	\N	\N
10805	1997-12-30	1998-01-27	1998-01-09	3	237.34	The Big Cheese	89 Jefferson Way Suite 2	Portland	OR	97201	USA	THEBI	77	2	\N	\N
10806	1997-12-31	1998-01-28	1998-01-05	2	22.11	Victuailles en stock	2, rue du Commerce	Lyon	\N	69004	France	VICTE	84	3	\N	\N
10807	1997-12-31	1998-01-28	1998-01-30	1	1.36	Franchi S.p.A.	Via Monte Bianco 34	Torino	\N	10100	Italy	FRANS	27	4	\N	\N
10808	1998-01-01	1998-01-29	1998-01-09	3	45.53	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA	OLDWO	55	2	\N	\N
10809	1998-01-01	1998-01-29	1998-01-07	1	4.87	Wellington Importadora	Rua do Mercado, 12	Resende	SP	08737-363	Brazil	WELLI	88	7	\N	\N
10810	1998-01-01	1998-01-29	1998-01-07	3	4.33	Laughing Bacchus Wine Cellars	2319 Elm St.	Vancouver	BC	V3F 2K1	Canada	LAUGB	42	2	\N	\N
10811	1998-01-02	1998-01-30	1998-01-08	1	31.22	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	LINOD	47	8	\N	\N
10812	1998-01-02	1998-01-30	1998-01-12	1	59.78	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	REGGC	66	5	\N	\N
10813	1998-01-05	1998-02-02	1998-01-09	1	47.38	Ricardo Adocicados	Av. Copacabana, 267	Rio de Janeiro	RJ	02389-890	Brazil	RICAR	67	1	\N	\N
10814	1998-01-05	1998-02-02	1998-01-14	3	130.94	Victuailles en stock	2, rue du Commerce	Lyon	\N	69004	France	VICTE	84	3	\N	\N
10815	1998-01-05	1998-02-02	1998-01-14	3	14.62	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	2	\N	\N
10816	1998-01-06	1998-02-03	1998-02-04	2	719.78	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA	GREAL	32	4	\N	\N
10817	1998-01-06	1998-01-20	1998-01-13	2	306.07	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	3	\N	\N
10818	1998-01-07	1998-02-04	1998-01-12	3	65.48	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy	MAGAA	49	7	\N	\N
10819	1998-01-07	1998-02-04	1998-01-16	3	19.76	Cactus Comidas para llevar	Cerrito 333	Buenos Aires	\N	1010	Argentina	CACTU	12	2	\N	\N
10820	1998-01-07	1998-02-04	1998-01-13	2	37.52	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	3	\N	\N
10821	1998-01-08	1998-02-05	1998-01-15	1	36.68	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA	SPLIR	75	1	\N	\N
10822	1998-01-08	1998-02-05	1998-01-16	3	7	Trail-s Head Gourmet Provisioners	722 DaVinci Blvd.	Kirkland	WA	98034	USA	TRAIH	82	6	\N	\N
10823	1998-01-09	1998-02-06	1998-01-13	2	163.97	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	5	\N	\N
10824	1998-01-09	1998-02-06	1998-01-30	1	1.23	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	8	\N	\N
10825	1998-01-09	1998-02-06	1998-01-14	1	79.25	Drachenblut Delikatessen	Walserweg 21	Aachen	\N	52066	Germany	DRACD	17	1	\N	\N
10826	1998-01-12	1998-02-09	1998-02-06	1	7.09	Blondel père et fils	24, place Kléber	Strasbourg	\N	67000	France	BLONP	7	6	\N	\N
10827	1998-01-12	1998-01-26	1998-02-06	2	63.54	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	1	\N	\N
10828	1998-01-13	1998-01-27	1998-02-04	1	90.85	Rancho grande	Av. del Libertador 900	Buenos Aires	\N	1010	Argentina	RANCH	64	9	\N	\N
10829	1998-01-13	1998-02-10	1998-01-23	1	154.72	Island Trading	Garden House Crowther Way	Cowes	Isle of Wight	PO31 7PJ	UK	ISLAT	38	9	\N	\N
10830	1998-01-13	1998-02-24	1998-01-21	2	81.83	Tradiçao Hipermercados	Av. Inês de Castro, 414	Sao Paulo	SP	05634-030	Brazil	TRADH	81	4	\N	\N
10831	1998-01-14	1998-02-11	1998-01-23	2	72.19	Santé Gourmet	Erling Skakkes gate 78	Stavern	\N	4110	Norway	SANTG	70	3	\N	\N
10832	1998-01-14	1998-02-11	1998-01-19	2	43.26	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	2	\N	\N
10833	1998-01-15	1998-02-12	1998-01-23	2	71.49	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany	OTTIK	56	6	\N	\N
10834	1998-01-15	1998-02-12	1998-01-19	3	29.78	Tradiçao Hipermercados	Av. Inês de Castro, 414	Sao Paulo	SP	05634-030	Brazil	TRADH	81	1	\N	\N
10835	1998-01-15	1998-02-12	1998-01-21	3	69.53	Alfred-s Futterkiste	Obere Str. 57	Berlin	\N	12209	Germany	ALFKI	1	1	\N	\N
10836	1998-01-16	1998-02-13	1998-01-21	1	411.88	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	7	\N	\N
10837	1998-01-16	1998-02-13	1998-01-23	3	13.32	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	9	\N	\N
10838	1998-01-19	1998-02-16	1998-01-23	3	59.28	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	LINOD	47	3	\N	\N
10839	1998-01-19	1998-02-16	1998-01-22	3	35.43	Tradiçao Hipermercados	Av. Inês de Castro, 414	Sao Paulo	SP	05634-030	Brazil	TRADH	81	3	\N	\N
10840	1998-01-19	1998-03-02	1998-02-16	2	2.71	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	LINOD	47	4	\N	\N
10841	1998-01-20	1998-02-17	1998-01-29	2	424.3	Suprêmes délices	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	SUPRD	76	5	\N	\N
10842	1998-01-20	1998-02-17	1998-01-29	3	54.42	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico	TORTU	80	1	\N	\N
10843	1998-01-21	1998-02-18	1998-01-26	2	9.26	Victuailles en stock	2, rue du Commerce	Lyon	\N	69004	France	VICTE	84	4	\N	\N
10844	1998-01-21	1998-02-18	1998-01-26	2	25.22	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria	PICCO	59	8	\N	\N
10845	1998-01-21	1998-02-04	1998-01-30	1	212.98	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	8	\N	\N
10846	1998-01-22	1998-03-05	1998-01-23	3	56.46	Suprêmes délices	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	SUPRD	76	2	\N	\N
10847	1998-01-22	1998-02-05	1998-02-10	3	487.57	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	4	\N	\N
10848	1998-01-23	1998-02-20	1998-01-29	2	38.24	Consolidated Holdings	Berkeley Gardens 12  Brewery	London	\N	WX1 6LT	UK	CONSH	16	7	\N	\N
10849	1998-01-23	1998-02-20	1998-01-30	2	0.56	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	9	\N	\N
10850	1998-01-23	1998-03-06	1998-01-30	1	49.19	Victuailles en stock	2, rue du Commerce	Lyon	\N	69004	France	VICTE	84	1	\N	\N
10851	1998-01-26	1998-02-23	1998-02-02	1	160.55	Ricardo Adocicados	Av. Copacabana, 267	Rio de Janeiro	RJ	02389-890	Brazil	RICAR	67	5	\N	\N
10852	1998-01-26	1998-02-09	1998-01-30	1	174.05	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	8	\N	\N
10853	1998-01-27	1998-02-24	1998-02-03	2	53.83	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany	BLAUS	6	9	\N	\N
10854	1998-01-27	1998-02-24	1998-02-05	2	100.22	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	3	\N	\N
10855	1998-01-27	1998-02-24	1998-02-04	1	170.97	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA	OLDWO	55	3	\N	\N
10856	1998-01-28	1998-02-25	1998-02-10	2	58.43	Antonio Moreno Taquería	Mataderos  2312	México D.F.	\N	5023	Mexico	ANTON	3	3	\N	\N
10857	1998-01-28	1998-02-25	1998-02-06	2	188.85	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	8	\N	\N
10858	1998-01-29	1998-02-26	1998-02-03	1	52.51	La corne d-abondance	67, avenue de l-Europe	Versailles	\N	78000	France	LACOR	40	2	\N	\N
10859	1998-01-29	1998-02-26	1998-02-02	2	76.1	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	1	\N	\N
10860	1998-01-29	1998-02-26	1998-02-04	3	19.26	France restauration	54, rue Royale	Nantes	\N	44000	France	FRANR	26	3	\N	\N
10861	1998-01-30	1998-02-27	1998-02-17	2	14.93	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	4	\N	\N
10862	1998-01-30	1998-03-13	1998-02-02	2	53.23	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	8	\N	\N
10863	1998-02-02	1998-03-02	1998-02-17	2	30.26	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	4	\N	\N
10864	1998-02-02	1998-03-02	1998-02-09	2	3.04	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	4	\N	\N
10865	1998-02-02	1998-02-16	1998-02-12	1	348.14	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	2	\N	\N
10866	1998-02-03	1998-03-03	1998-02-12	1	109.11	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	5	\N	\N
10867	1998-02-03	1998-03-17	1998-02-11	1	1.93	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA	LONEP	48	6	\N	\N
10868	1998-02-04	1998-03-04	1998-02-23	2	191.27	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	7	\N	\N
10869	1998-02-04	1998-03-04	1998-02-09	1	143.28	Seven Seas Imports	90 Wadhurst Rd.	London	\N	OX15 4NB	UK	SEVES	72	5	\N	\N
10870	1998-02-04	1998-03-04	1998-02-13	3	12.04	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland	WOLZA	91	5	\N	\N
10871	1998-02-05	1998-03-05	1998-02-10	2	112.27	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	9	\N	\N
10872	1998-02-05	1998-03-05	1998-02-09	2	175.32	Godos Cocina Típica	C/ Romero, 33	Sevilla	\N	41101	Spain	GODOS	30	5	\N	\N
10873	1998-02-06	1998-03-06	1998-02-09	1	0.82	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland	WILMK	90	4	\N	\N
10874	1998-02-06	1998-03-06	1998-02-11	2	19.58	Godos Cocina Típica	C/ Romero, 33	Sevilla	\N	41101	Spain	GODOS	30	5	\N	\N
10875	1998-02-06	1998-03-06	1998-03-03	2	32.37	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	4	\N	\N
10876	1998-02-09	1998-03-09	1998-02-12	3	60.42	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	7	\N	\N
10877	1998-02-09	1998-03-09	1998-02-19	1	38.06	Ricardo Adocicados	Av. Copacabana, 267	Rio de Janeiro	RJ	02389-890	Brazil	RICAR	67	1	\N	\N
10878	1998-02-10	1998-03-10	1998-02-12	1	46.69	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	4	\N	\N
10879	1998-02-10	1998-03-10	1998-02-12	3	8.5	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland	WILMK	90	3	\N	\N
10880	1998-02-10	1998-03-24	1998-02-18	1	88.01	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	7	\N	\N
10881	1998-02-11	1998-03-11	1998-02-18	1	2.84	Cactus Comidas para llevar	Cerrito 333	Buenos Aires	\N	1010	Argentina	CACTU	12	4	\N	\N
10882	1998-02-11	1998-03-11	1998-02-20	3	23.1	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	4	\N	\N
10883	1998-02-12	1998-03-12	1998-02-20	3	0.53	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA	LONEP	48	8	\N	\N
10884	1998-02-12	1998-03-12	1998-02-13	2	90.97	Let-s Stop N Shop	87 Polk St. Suite 5	San Francisco	CA	94117	USA	LETSS	45	4	\N	\N
10885	1998-02-12	1998-03-12	1998-02-18	3	5.64	Suprêmes délices	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	SUPRD	76	6	\N	\N
10886	1998-02-13	1998-03-13	1998-03-02	1	4.99	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	1	\N	\N
10887	1998-02-13	1998-03-13	1998-02-16	3	1.25	Galería del gastronómo	Rambla de Cataluña, 23	Barcelona	\N	8022	Spain	GALED	29	8	\N	\N
10888	1998-02-16	1998-03-16	1998-02-23	2	51.87	Godos Cocina Típica	C/ Romero, 33	Sevilla	\N	41101	Spain	GODOS	30	1	\N	\N
10889	1998-02-16	1998-03-16	1998-02-23	3	280.61	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	9	\N	\N
10890	1998-02-16	1998-03-16	1998-02-18	1	32.76	Du monde entier	67, rue des Cinquante Otages	Nantes	\N	44000	France	DUMON	18	7	\N	\N
10891	1998-02-17	1998-03-17	1998-02-19	2	20.37	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	7	\N	\N
10892	1998-02-17	1998-03-17	1998-02-19	2	120.27	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium	MAISD	50	4	\N	\N
10893	1998-02-18	1998-03-18	1998-02-20	2	77.78	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	9	\N	\N
10894	1998-02-18	1998-03-18	1998-02-20	1	116.13	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	1	\N	\N
10895	1998-02-18	1998-03-18	1998-02-23	1	162.75	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	3	\N	\N
10896	1998-02-19	1998-03-19	1998-02-27	3	32.45	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium	MAISD	50	7	\N	\N
10897	1998-02-19	1998-03-19	1998-02-25	2	603.54	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	3	\N	\N
10898	1998-02-20	1998-03-20	1998-03-06	2	1.27	Océano Atlántico Ltda.	Ing. Gustavo Moncada 8585 Piso 20-A	Buenos Aires	\N	1010	Argentina	OCEAN	54	4	\N	\N
10899	1998-02-20	1998-03-20	1998-02-26	3	1.21	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	5	\N	\N
10900	1998-02-20	1998-03-20	1998-03-04	2	1.66	Wellington Importadora	Rua do Mercado, 12	Resende	SP	08737-363	Brazil	WELLI	88	1	\N	\N
10901	1998-02-23	1998-03-23	1998-02-26	1	62.09	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	4	\N	\N
10902	1998-02-23	1998-03-23	1998-03-03	1	44.15	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	1	\N	\N
10903	1998-02-24	1998-03-24	1998-03-04	3	36.71	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	3	\N	\N
10904	1998-02-24	1998-03-24	1998-02-27	3	162.95	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	3	\N	\N
10905	1998-02-24	1998-03-24	1998-03-06	2	13.72	Wellington Importadora	Rua do Mercado, 12	Resende	SP	08737-363	Brazil	WELLI	88	9	\N	\N
10906	1998-02-25	1998-03-11	1998-03-03	3	26.29	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland	WOLZA	91	4	\N	\N
10907	1998-02-25	1998-03-25	1998-02-27	3	9.19	Spécialités du monde	25, rue Lauriston	Paris	\N	75016	France	SPECD	74	6	\N	\N
10908	1998-02-26	1998-03-26	1998-03-06	2	32.96	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	REGGC	66	4	\N	\N
10909	1998-02-26	1998-03-26	1998-03-10	2	53.05	Santé Gourmet	Erling Skakkes gate 78	Stavern	\N	4110	Norway	SANTG	70	1	\N	\N
10910	1998-02-26	1998-03-26	1998-03-04	3	38.11	Wilman Kala	Keskuskatu 45	Helsinki	\N	21240	Finland	WILMK	90	1	\N	\N
10911	1998-02-26	1998-03-26	1998-03-05	1	38.19	Godos Cocina Típica	C/ Romero, 33	Sevilla	\N	41101	Spain	GODOS	30	3	\N	\N
10912	1998-02-26	1998-03-26	1998-03-18	2	580.91	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	2	\N	\N
10913	1998-02-26	1998-03-26	1998-03-04	1	33.05	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	4	\N	\N
10914	1998-02-27	1998-03-27	1998-03-02	1	21.19	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	6	\N	\N
10915	1998-02-27	1998-03-27	1998-03-02	2	3.51	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico	TORTU	80	2	\N	\N
10916	1998-02-27	1998-03-27	1998-03-09	2	63.77	Rancho grande	Av. del Libertador 900	Buenos Aires	\N	1010	Argentina	RANCH	64	1	\N	\N
10917	1998-03-02	1998-03-30	1998-03-11	2	8.29	Romero y tomillo	Gran Vía, 1	Madrid	\N	28001	Spain	ROMEY	69	4	\N	\N
10918	1998-03-02	1998-03-30	1998-03-11	3	48.83	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	3	\N	\N
10919	1998-03-02	1998-03-30	1998-03-04	2	19.8	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	LINOD	47	2	\N	\N
10920	1998-03-03	1998-03-31	1998-03-09	2	29.61	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	4	\N	\N
10921	1998-03-03	1998-04-14	1998-03-09	1	176.48	Vaffeljernet	Smagsloget 45	Århus	\N	8200	Denmark	VAFFE	83	1	\N	\N
10922	1998-03-03	1998-03-31	1998-03-05	3	62.74	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	5	\N	\N
10923	1998-03-03	1998-04-14	1998-03-13	3	68.26	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	7	\N	\N
10924	1998-03-04	1998-04-01	1998-04-08	2	151.52	Berglunds snabbköp	Berguvsvägen  8	Luleå	\N	S-958 22	Sweden	BERGS	5	3	\N	\N
10925	1998-03-04	1998-04-01	1998-03-13	1	2.27	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	3	\N	\N
10926	1998-03-04	1998-04-01	1998-03-11	3	39.92	Ana Trujillo Emparedados y helados	Avda. de la Constitución 2222	México D.F.	\N	5021	Mexico	ANATR	2	4	\N	\N
10927	1998-03-05	1998-04-02	1998-04-08	1	19.79	La corne d-abondance	67, avenue de l-Europe	Versailles	\N	78000	France	LACOR	40	4	\N	\N
10928	1998-03-05	1998-04-02	1998-03-18	1	1.36	Galería del gastronómo	Rambla de Cataluña, 23	Barcelona	\N	8022	Spain	GALED	29	1	\N	\N
10929	1998-03-05	1998-04-02	1998-03-12	1	33.93	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	6	\N	\N
10930	1998-03-06	1998-04-17	1998-03-18	3	15.55	Suprêmes délices	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	SUPRD	76	4	\N	\N
10931	1998-03-06	1998-03-20	1998-03-19	2	13.6	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland	RICSU	68	4	\N	\N
10932	1998-03-06	1998-04-03	1998-03-24	1	134.64	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	8	\N	\N
10933	1998-03-06	1998-04-03	1998-03-16	3	54.15	Island Trading	Garden House Crowther Way	Cowes	Isle of Wight	PO31 7PJ	UK	ISLAT	38	6	\N	\N
10934	1998-03-09	1998-04-06	1998-03-12	3	32.01	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	3	\N	\N
10935	1998-03-09	1998-04-06	1998-03-18	3	47.59	Wellington Importadora	Rua do Mercado, 12	Resende	SP	08737-363	Brazil	WELLI	88	4	\N	\N
10936	1998-03-09	1998-04-06	1998-03-18	2	33.68	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA	GREAL	32	3	\N	\N
10937	1998-03-10	1998-03-24	1998-03-13	3	31.51	Cactus Comidas para llevar	Cerrito 333	Buenos Aires	\N	1010	Argentina	CACTU	12	7	\N	\N
10938	1998-03-10	1998-04-07	1998-03-16	2	31.89	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	3	\N	\N
10939	1998-03-10	1998-04-07	1998-03-13	2	76.33	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy	MAGAA	49	2	\N	\N
10940	1998-03-11	1998-04-08	1998-03-23	3	19.77	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	8	\N	\N
10941	1998-03-11	1998-04-08	1998-03-20	2	400.81	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	7	\N	\N
10942	1998-03-11	1998-04-08	1998-03-18	3	17.95	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	REGGC	66	9	\N	\N
10943	1998-03-11	1998-04-08	1998-03-19	2	2.17	B-s Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK	BSBEV	11	4	\N	\N
10944	1998-03-12	1998-03-26	1998-03-13	3	52.92	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	6	\N	\N
10945	1998-03-12	1998-04-09	1998-03-18	1	10.22	Morgenstern Gesundkost	Heerstr. 22	Leipzig	\N	4179	Germany	MORGK	52	4	\N	\N
10946	1998-03-12	1998-04-09	1998-03-19	2	27.2	Vaffeljernet	Smagsloget 45	Århus	\N	8200	Denmark	VAFFE	83	1	\N	\N
10947	1998-03-13	1998-04-10	1998-03-16	2	3.26	B-s Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK	BSBEV	11	3	\N	\N
10948	1998-03-13	1998-04-10	1998-03-19	3	23.39	Godos Cocina Típica	C/ Romero, 33	Sevilla	\N	41101	Spain	GODOS	30	3	\N	\N
10949	1998-03-13	1998-04-10	1998-03-17	3	74.44	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	2	\N	\N
10950	1998-03-16	1998-04-13	1998-03-23	2	2.5	Magazzini Alimentari Riuniti	Via Ludovico il Moro 22	Bergamo	\N	24100	Italy	MAGAA	49	1	\N	\N
10951	1998-03-16	1998-04-27	1998-04-07	2	30.85	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland	RICSU	68	9	\N	\N
10952	1998-03-16	1998-04-27	1998-03-24	1	40.42	Alfred-s Futterkiste	Obere Str. 57	Berlin	\N	12209	Germany	ALFKI	1	1	\N	\N
10953	1998-03-16	1998-03-30	1998-03-25	2	23.72	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	9	\N	\N
10954	1998-03-17	1998-04-28	1998-03-20	1	27.91	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	LINOD	47	5	\N	\N
10955	1998-03-17	1998-04-14	1998-03-20	2	3.26	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	8	\N	\N
10956	1998-03-17	1998-04-28	1998-03-20	2	44.65	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany	BLAUS	6	6	\N	\N
10957	1998-03-18	1998-04-15	1998-03-27	3	105.36	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	8	\N	\N
10958	1998-03-18	1998-04-15	1998-03-27	2	49.56	Océano Atlántico Ltda.	Ing. Gustavo Moncada 8585 Piso 20-A	Buenos Aires	\N	1010	Argentina	OCEAN	54	7	\N	\N
10959	1998-03-18	1998-04-29	1998-03-23	2	4.98	Gourmet Lanchonetes	Av. Brasil, 442	Campinas	SP	04876-786	Brazil	GOURL	31	6	\N	\N
10960	1998-03-19	1998-04-02	1998-04-08	1	2.08	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	3	\N	\N
10961	1998-03-19	1998-04-16	1998-03-30	1	104.47	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	8	\N	\N
10962	1998-03-19	1998-04-16	1998-03-23	2	275.79	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	8	\N	\N
10963	1998-03-19	1998-04-16	1998-03-26	3	2.7	Furia Bacalhau e Frutos do Mar	Jardim das rosas n. 32	Lisboa	\N	1675	Portugal	FURIB	28	9	\N	\N
10964	1998-03-20	1998-04-17	1998-03-24	2	87.38	Spécialités du monde	25, rue Lauriston	Paris	\N	75016	France	SPECD	74	3	\N	\N
10965	1998-03-20	1998-04-17	1998-03-30	3	144.38	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA	OLDWO	55	6	\N	\N
10966	1998-03-20	1998-04-17	1998-04-08	1	27.19	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland	CHOPS	14	4	\N	\N
10967	1998-03-23	1998-04-20	1998-04-02	2	62.22	Toms Spezialitäten	Luisenstr. 48	Münster	\N	44087	Germany	TOMSP	79	2	\N	\N
10968	1998-03-23	1998-04-20	1998-04-01	3	74.6	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	1	\N	\N
10969	1998-03-23	1998-04-20	1998-03-30	2	0.21	Comércio Mineiro	Av. dos Lusíadas, 23	Sao Paulo	SP	05432-043	Brazil	COMMI	15	1	\N	\N
10970	1998-03-24	1998-04-07	1998-04-24	1	16.16	Bólido Comidas preparadas	C/ Araquil, 67	Madrid	\N	28023	Spain	BOLID	8	9	\N	\N
10971	1998-03-24	1998-04-21	1998-04-02	2	121.82	France restauration	54, rue Royale	Nantes	\N	44000	France	FRANR	26	2	\N	\N
10972	1998-03-24	1998-04-21	1998-03-26	2	0.02	La corne d-abondance	67, avenue de l-Europe	Versailles	\N	78000	France	LACOR	40	4	\N	\N
10973	1998-03-24	1998-04-21	1998-03-27	2	15.17	La corne d-abondance	67, avenue de l-Europe	Versailles	\N	78000	France	LACOR	40	6	\N	\N
10974	1998-03-25	1998-04-08	1998-04-03	3	12.96	Split Rail Beer & Ale	P.O. Box 555	Lander	WY	82520	USA	SPLIR	75	3	\N	\N
10975	1998-03-25	1998-04-22	1998-03-27	3	32.27	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	1	\N	\N
10976	1998-03-25	1998-05-06	1998-04-03	1	37.97	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	1	\N	\N
10977	1998-03-26	1998-04-23	1998-04-10	3	208.5	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	8	\N	\N
10978	1998-03-26	1998-04-23	1998-04-23	2	32.82	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium	MAISD	50	9	\N	\N
10979	1998-03-26	1998-04-23	1998-03-31	2	353.07	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	8	\N	\N
10980	1998-03-27	1998-05-08	1998-04-17	1	1.26	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	4	\N	\N
10981	1998-03-27	1998-04-24	1998-04-02	2	193.37	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	1	\N	\N
10982	1998-03-27	1998-04-24	1998-04-08	1	14.01	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	2	\N	\N
10983	1998-03-27	1998-04-24	1998-04-06	2	657.54	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	2	\N	\N
10984	1998-03-30	1998-04-27	1998-04-03	3	211.22	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	1	\N	\N
10985	1998-03-30	1998-04-27	1998-04-02	1	91.51	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	2	\N	\N
10986	1998-03-30	1998-04-27	1998-04-21	2	217.86	Océano Atlántico Ltda.	Ing. Gustavo Moncada 8585 Piso 20-A	Buenos Aires	\N	1010	Argentina	OCEAN	54	8	\N	\N
10987	1998-03-31	1998-04-28	1998-04-06	1	185.48	Eastern Connection	35 King George	London	\N	WX3 6FW	UK	EASTC	19	8	\N	\N
10988	1998-03-31	1998-04-28	1998-04-10	2	61.14	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	3	\N	\N
10989	1998-03-31	1998-04-28	1998-04-02	1	34.76	Que Delícia	Rua da Panificadora, 12	Rio de Janeiro	RJ	02389-673	Brazil	QUEDE	61	2	\N	\N
10990	1998-04-01	1998-05-13	1998-04-07	3	117.61	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	2	\N	\N
10991	1998-04-01	1998-04-29	1998-04-07	1	38.51	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	1	\N	\N
10992	1998-04-01	1998-04-29	1998-04-03	3	4.27	The Big Cheese	89 Jefferson Way Suite 2	Portland	OR	97201	USA	THEBI	77	1	\N	\N
10993	1998-04-01	1998-04-29	1998-04-10	3	8.81	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	7	\N	\N
10994	1998-04-02	1998-04-16	1998-04-09	3	65.53	Vaffeljernet	Smagsloget 45	Århus	\N	8200	Denmark	VAFFE	83	2	\N	\N
10995	1998-04-02	1998-04-30	1998-04-06	3	46	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	México D.F.	\N	5033	Mexico	PERIC	58	1	\N	\N
10996	1998-04-02	1998-04-30	1998-04-10	2	1.12	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	4	\N	\N
10997	1998-04-03	1998-05-15	1998-04-13	2	73.91	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	8	\N	\N
10998	1998-04-03	1998-04-17	1998-04-17	2	20.31	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland	WOLZA	91	8	\N	\N
10999	1998-04-03	1998-05-01	1998-04-10	2	96.35	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany	OTTIK	56	6	\N	\N
11000	1998-04-06	1998-05-04	1998-04-14	3	55.12	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	2	\N	\N
11001	1998-04-06	1998-05-04	1998-04-14	2	197.3	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	2	\N	\N
11002	1998-04-06	1998-05-04	1998-04-16	1	141.16	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	4	\N	\N
11003	1998-04-06	1998-05-04	1998-04-08	3	14.91	The Cracker Box	55 Grizzly Peak Rd.	Butte	MT	59801	USA	THECR	78	3	\N	\N
11004	1998-04-07	1998-05-05	1998-04-20	1	44.84	Maison Dewey	Rue Joseph-Bens 532	Bruxelles	\N	B-1180	Belgium	MAISD	50	3	\N	\N
11006	1998-04-07	1998-05-05	1998-04-15	2	25.19	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA	GREAL	32	3	\N	\N
11007	1998-04-08	1998-05-06	1998-04-13	2	202.24	Princesa Isabel Vinhos	Estrada da saúde n. 58	Lisboa	\N	1756	Portugal	PRINI	60	8	\N	\N
11008	1998-04-08	1998-05-06	\N	3	79.46	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	7	\N	\N
11009	1998-04-08	1998-05-06	1998-04-10	1	59.11	Godos Cocina Típica	C/ Romero, 33	Sevilla	\N	41101	Spain	GODOS	30	2	\N	\N
11010	1998-04-09	1998-05-07	1998-04-21	2	28.71	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	REGGC	66	2	\N	\N
11011	1998-04-09	1998-05-07	1998-04-13	1	1.21	Alfred-s Futterkiste	Obere Str. 57	Berlin	\N	12209	Germany	ALFKI	1	3	\N	\N
11012	1998-04-09	1998-04-23	1998-04-17	3	242.95	Frankenversand	Berliner Platz 43	München	\N	80805	Germany	FRANK	25	1	\N	\N
11013	1998-04-09	1998-05-07	1998-04-10	1	32.99	Romero y tomillo	Gran Vía, 1	Madrid	\N	28001	Spain	ROMEY	69	2	\N	\N
11014	1998-04-10	1998-05-08	1998-04-15	3	23.6	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	LINOD	47	2	\N	\N
11015	1998-04-10	1998-04-24	1998-04-20	2	4.62	Santé Gourmet	Erling Skakkes gate 78	Stavern	\N	4110	Norway	SANTG	70	2	\N	\N
11016	1998-04-10	1998-05-08	1998-04-13	2	33.8	Around the Horn	Brook Farm Stratford St. Mary	Colchester	Essex	CO7 6JX	UK	AROUT	4	9	\N	\N
11017	1998-04-13	1998-05-11	1998-04-20	2	754.26	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	9	\N	\N
11018	1998-04-13	1998-05-11	1998-04-16	2	11.65	Lonesome Pine Restaurant	89 Chiaroscuro Rd.	Portland	OR	97219	USA	LONEP	48	4	\N	\N
11019	1998-04-13	1998-05-11	\N	3	3.17	Rancho grande	Av. del Libertador 900	Buenos Aires	\N	1010	Argentina	RANCH	64	6	\N	\N
11020	1998-04-14	1998-05-12	1998-04-16	2	43.3	Ottilies Käseladen	Mehrheimerstr. 369	Köln	\N	50739	Germany	OTTIK	56	2	\N	\N
11021	1998-04-14	1998-05-12	1998-04-21	1	297.18	QUICK-Stop	Taucherstraße 10	Cunewalde	\N	1307	Germany	QUICK	63	3	\N	\N
11022	1998-04-14	1998-05-12	1998-05-04	2	6.27	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	9	\N	\N
11023	1998-04-14	1998-04-28	1998-04-24	2	123.83	B-s Beverages	Fauntleroy Circus	London	\N	EC2 5NT	UK	BSBEV	11	1	\N	\N
11024	1998-04-15	1998-05-13	1998-04-20	1	74.36	Eastern Connection	35 King George	London	\N	WX3 6FW	UK	EASTC	19	4	\N	\N
11025	1998-04-15	1998-05-13	1998-04-24	3	29.17	Wartian Herkku	Torikatu 38	Oulu	\N	90110	Finland	WARTH	87	6	\N	\N
11026	1998-04-15	1998-05-13	1998-04-28	1	47.09	Franchi S.p.A.	Via Monte Bianco 34	Torino	\N	10100	Italy	FRANS	27	4	\N	\N
11027	1998-04-16	1998-05-14	1998-04-20	1	52.52	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	1	\N	\N
11028	1998-04-16	1998-05-14	1998-04-22	1	29.59	Königlich Essen	Maubelstr. 90	Brandenburg	\N	14776	Germany	KOENE	39	2	\N	\N
11029	1998-04-16	1998-05-14	1998-04-27	1	47.84	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland	CHOPS	14	4	\N	\N
11030	1998-04-17	1998-05-15	1998-04-27	2	830.75	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	7	\N	\N
11031	1998-04-17	1998-05-15	1998-04-24	2	227.22	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	6	\N	\N
11032	1998-04-17	1998-05-15	1998-04-23	3	606.19	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	2	\N	\N
11033	1998-04-17	1998-05-15	1998-04-23	3	84.74	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland	RICSU	68	7	\N	\N
11034	1998-04-20	1998-06-01	1998-04-27	1	40.32	Old World Delicatessen	2743 Bering St.	Anchorage	AK	99508	USA	OLDWO	55	8	\N	\N
11035	1998-04-20	1998-05-18	1998-04-24	2	0.17	Suprêmes délices	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	SUPRD	76	2	\N	\N
11036	1998-04-20	1998-05-18	1998-04-22	3	149.47	Drachenblut Delikatessen	Walserweg 21	Aachen	\N	52066	Germany	DRACD	17	8	\N	\N
11037	1998-04-21	1998-05-19	1998-04-27	1	3.2	Godos Cocina Típica	C/ Romero, 33	Sevilla	\N	41101	Spain	GODOS	30	7	\N	\N
11038	1998-04-21	1998-05-19	1998-04-30	2	29.59	Suprêmes délices	Boulevard Tirou, 255	Charleroi	\N	B-6000	Belgium	SUPRD	76	1	\N	\N
11039	1998-04-21	1998-05-19	\N	2	65	LINO-Delicateses	Ave. 5 de Mayo Porlamar	I. de Margarita	Nueva Esparta	4980	Venezuela	LINOD	47	1	\N	\N
11040	1998-04-22	1998-05-20	\N	3	18.84	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA	GREAL	32	4	\N	\N
11041	1998-04-22	1998-05-20	1998-04-28	2	48.22	Chop-suey Chinese	Hauptstr. 31	Bern	\N	3012	Switzerland	CHOPS	14	3	\N	\N
11042	1998-04-22	1998-05-06	1998-05-01	1	29.99	Comércio Mineiro	Av. dos Lusíadas, 23	Sao Paulo	SP	05432-043	Brazil	COMMI	15	2	\N	\N
11043	1998-04-22	1998-05-20	1998-04-29	2	8.8	Spécialités du monde	25, rue Lauriston	Paris	\N	75016	France	SPECD	74	5	\N	\N
11044	1998-04-23	1998-05-21	1998-05-01	1	8.72	Wolski Zajazd	ul. Filtrowa 68	Warszawa	\N	01-012	Poland	WOLZA	91	4	\N	\N
11045	1998-04-23	1998-05-21	\N	2	70.58	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	6	\N	\N
11046	1998-04-23	1998-05-21	1998-04-24	2	71.64	Die Wandernde Kuh	Adenauerallee 900	Stuttgart	\N	70563	Germany	WANDK	86	8	\N	\N
11047	1998-04-24	1998-05-22	1998-05-01	3	46.62	Eastern Connection	35 King George	London	\N	WX3 6FW	UK	EASTC	19	7	\N	\N
11048	1998-04-24	1998-05-22	1998-04-30	3	24.12	Bottom-Dollar Markets	23 Tsawassen Blvd.	Tsawassen	BC	T2F 8M4	Canada	BOTTM	10	7	\N	\N
11049	1998-04-24	1998-05-22	1998-05-04	1	8.34	Gourmet Lanchonetes	Av. Brasil, 442	Campinas	SP	04876-786	Brazil	GOURL	31	3	\N	\N
11050	1998-04-27	1998-05-25	1998-05-05	2	59.41	Folk och fä HB	Åkergatan 24	Bräcke	\N	S-844 67	Sweden	FOLKO	24	8	\N	\N
11051	1998-04-27	1998-05-25	\N	3	2.79	La maison d-Asie	1 rue Alsace-Lorraine	Toulouse	\N	31000	France	LAMAI	41	7	\N	\N
11052	1998-04-27	1998-05-25	1998-05-01	1	67.26	Hanari Carnes	Rua do Paço, 67	Rio de Janeiro	RJ	05454-876	Brazil	HANAR	34	3	\N	\N
11053	1998-04-27	1998-05-25	1998-04-29	2	53.05	Piccolo und mehr	Geislweg 14	Salzburg	\N	5020	Austria	PICCO	59	2	\N	\N
11054	1998-04-28	1998-05-26	\N	1	0.33	Cactus Comidas para llevar	Cerrito 333	Buenos Aires	\N	1010	Argentina	CACTU	12	8	\N	\N
11055	1998-04-28	1998-05-26	1998-05-05	2	120.92	HILARION-Abastos	Carrera 22 con Ave. Carlos Soublette #8-35	San Cristóbal	Táchira	5022	Venezuela	HILAA	35	7	\N	\N
11056	1998-04-28	1998-05-12	1998-05-01	2	278.96	Eastern Connection	35 King George	London	\N	WX3 6FW	UK	EASTC	19	8	\N	\N
11057	1998-04-29	1998-05-27	1998-05-01	3	4.13	North/South	South House 300 Queensbridge	London	\N	SW7 1RZ	UK	NORTS	53	3	\N	\N
11058	1998-04-29	1998-05-27	\N	3	31.14	Blauer See Delikatessen	Forsterstr. 57	Mannheim	\N	68306	Germany	BLAUS	6	9	\N	\N
11059	1998-04-29	1998-06-10	\N	2	85.8	Ricardo Adocicados	Av. Copacabana, 267	Rio de Janeiro	RJ	02389-890	Brazil	RICAR	67	2	\N	\N
11060	1998-04-30	1998-05-28	1998-05-04	2	10.98	Franchi S.p.A.	Via Monte Bianco 34	Torino	\N	10100	Italy	FRANS	27	2	\N	\N
11061	1998-04-30	1998-06-11	\N	3	14.01	Great Lakes Food Market	2732 Baker Blvd.	Eugene	OR	97403	USA	GREAL	32	4	\N	\N
11062	1998-04-30	1998-05-28	\N	2	29.93	Reggiani Caseifici	Strada Provinciale 124	Reggio Emilia	\N	42100	Italy	REGGC	66	4	\N	\N
11063	1998-04-30	1998-05-28	1998-05-06	2	81.73	Hungry Owl All-Night Grocers	8 Johnstown Road	Cork	Co. Cork	\N	Ireland	HUNGO	37	3	\N	\N
11064	1998-05-01	1998-05-29	1998-05-04	1	30.09	Save-a-lot Markets	187 Suffolk Ln.	Boise	ID	83720	USA	SAVEA	71	1	\N	\N
11065	1998-05-01	1998-05-29	\N	1	12.91	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	8	\N	\N
11066	1998-05-01	1998-05-29	1998-05-04	2	44.72	White Clover Markets	1029 - 12th Ave. S.	Seattle	WA	98124	USA	WHITC	89	7	\N	\N
11067	1998-05-04	1998-05-18	1998-05-06	2	7.98	Drachenblut Delikatessen	Walserweg 21	Aachen	\N	52066	Germany	DRACD	17	1	\N	\N
11068	1998-05-04	1998-06-01	\N	2	81.75	Queen Cozinha	Alameda dos Canàrios, 891	Sao Paulo	SP	05487-020	Brazil	QUEEN	62	8	\N	\N
11069	1998-05-04	1998-06-01	1998-05-06	2	15.67	Tortuga Restaurante	Avda. Azteca 123	México D.F.	\N	5033	Mexico	TORTU	80	1	\N	\N
11070	1998-05-05	1998-06-02	\N	1	136	Lehmanns Marktstand	Magazinweg 7	Frankfurt a.M.	\N	60528	Germany	LEHMS	44	2	\N	\N
11071	1998-05-05	1998-06-02	\N	1	0.93	LILA-Supermercado	Carrera 52 con Ave. Bolívar #65-98 Llano Largo	Barquisimeto	Lara	3508	Venezuela	LILAS	46	1	\N	\N
11072	1998-05-05	1998-06-02	\N	2	258.64	Ernst Handel	Kirchgasse 6	Graz	\N	8010	Austria	ERNSH	20	4	\N	\N
11073	1998-05-05	1998-06-02	\N	2	24.95	Pericles Comidas clásicas	Calle Dr. Jorge Cash 321	México D.F.	\N	5033	Mexico	PERIC	58	2	\N	\N
11074	1998-05-06	1998-06-03	\N	2	18.44	Simons bistro	Vinbæltet 34	Kobenhavn	\N	1734	Denmark	SIMOB	73	7	\N	\N
11075	1998-05-06	1998-06-03	\N	2	6.19	Richter Supermarkt	Starenweg 5	Genève	\N	1204	Switzerland	RICSU	68	8	\N	\N
11076	1998-05-06	1998-06-03	\N	2	38.28	Bon app-	12, rue des Bouchers	Marseille	\N	13008	France	BONAP	9	4	\N	\N
11077	1998-05-06	1998-06-03	\N	2	8.53	Rattlesnake Canyon Grocery	2817 Milton Dr.	Albuquerque	NM	87110	USA	RATTC	65	1	\N	\N
\.


--
-- Name: orders_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('orders_id_seq', 11077, true);


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY products (id, product_name, quantity_per_unit, unit_price, units_in_stock, units_on_order, reorder_level, discontinued, supplier_id, category_id, created_at, updated_at) FROM stdin;
1	Chai	10 boxes x 30 bags	18	39	0	10	t	8	1	\N	\N
2	Chang	24 - 12 oz bottles	19	17	40	25	t	1	1	\N	\N
3	Aniseed Syrup	12 - 550 ml bottles	10	13	70	25	f	1	2	\N	\N
4	Chef Anton's Cajun Seasoning	48 - 6 oz jars	22	53	0	0	f	2	2	\N	\N
5	Chef Anton's Gumbo Mix	36 boxes	21.35	0	0	0	t	2	2	\N	\N
6	Grandma's Boysenberry Spread	12 - 8 oz jars	25	120	0	25	f	3	2	\N	\N
7	Uncle Bob's Organic Dried Pears	12 - 1 lb pkgs.	30	15	0	10	f	3	7	\N	\N
8	Northwoods Cranberry Sauce	12 - 12 oz jars	40	6	0	0	f	3	2	\N	\N
9	Mishi Kobe Niku	18 - 500 g pkgs.	97	29	0	0	t	4	6	\N	\N
10	Ikura	12 - 200 ml jars	31	31	0	0	f	4	8	\N	\N
11	Queso Cabrales	1 kg pkg.	21	22	30	30	f	5	4	\N	\N
12	Queso Manchego La Pastora	10 - 500 g pkgs.	38	86	0	0	f	5	4	\N	\N
13	Konbu	2 kg box	6	24	0	5	f	6	8	\N	\N
14	Tofu	40 - 100 g pkgs.	23.25	35	0	0	f	6	7	\N	\N
15	Genen Shouyu	24 - 250 ml bottles	13	39	0	5	f	6	2	\N	\N
16	Pavlova	32 - 500 g boxes	17.45	29	0	10	f	7	3	\N	\N
17	Alice Mutton	20 - 1 kg tins	39	0	0	0	t	7	6	\N	\N
18	Carnarvon Tigers	16 kg pkg.	62.5	42	0	0	f	7	8	\N	\N
19	Teatime Chocolate Biscuits	10 boxes x 12 pieces	9.20	25	0	5	f	8	3	\N	\N
20	Sir Rodney's Marmalade	30 gift boxes	81	40	0	0	f	8	3	\N	\N
21	Sir Rodney's Scones	24 pkgs. x 4 pieces	10	3	40	5	f	8	3	\N	\N
22	Gustaf's Knäckebröd	24 - 500 g pkgs.	21	104	0	25	f	9	5	\N	\N
23	Tunnbröd	12 - 250 g pkgs.	9	61	0	25	f	9	5	\N	\N
24	Guaraná Fantástica	12 - 355 ml cans	4.5	20	0	0	t	10	1	\N	\N
25	NuNuCa Nuß-Nougat-Creme	20 - 450 g glasses	14	76	0	30	f	11	3	\N	\N
26	Gumbär Gummibärchen	100 - 250 g bags	31.23	15	0	0	f	11	3	\N	\N
27	Schoggi Schokolade	100 - 100 g pieces	43.90	49	0	30	f	11	3	\N	\N
28	Rössle Sauerkraut	25 - 825 g cans	45.60	26	0	0	t	12	7	\N	\N
29	Thüringer Rostbratwurst	50 bags x 30 sausgs.	123.79	0	0	0	t	12	6	\N	\N
30	Nord-Ost Matjeshering	10 - 200 g glasses	25.89	10	0	15	f	13	8	\N	\N
31	Gorgonzola Telino	12 - 100 g pkgs	12.5	0	70	20	f	14	4	\N	\N
32	Mascarpone Fabioli	24 - 200 g pkgs.	32	9	40	25	f	14	4	\N	\N
33	Geitost	500 g	2.5	112	0	20	f	15	4	\N	\N
34	Sasquatch Ale	24 - 12 oz bottles	14	111	0	15	f	16	1	\N	\N
35	Steeleye Stout	24 - 12 oz bottles	18	20	0	15	f	16	1	\N	\N
36	Inlagd Sill	24 - 250 g  jars	19	112	0	20	f	17	8	\N	\N
37	Gravad lax	12 - 500 g pkgs.	26	11	50	25	f	17	8	\N	\N
38	Côte de Blaye	12 - 75 cl bottles	263.5	17	0	15	f	18	1	\N	\N
39	Chartreuse verte	750 cc per bottle	18	69	0	5	f	18	1	\N	\N
40	Boston Crab Meat	24 - 4 oz tins	18.40	123	0	30	f	19	8	\N	\N
41	Jack's New England Clam Chowder	12 - 12 oz cans	9.65	85	0	10	f	19	8	\N	\N
42	Singaporean Hokkien Fried Mee	32 - 1 kg pkgs.	14	26	0	0	t	20	5	\N	\N
43	Ipoh Coffee	16 - 500 g tins	46	17	10	25	f	20	1	\N	\N
44	Gula Malacca	20 - 2 kg bags	19.45	27	0	15	f	20	2	\N	\N
45	Rogede sild	1k pkg.	9.5	5	70	15	f	21	8	\N	\N
46	Spegesild	4 - 450 g glasses	12	95	0	0	f	21	8	\N	\N
47	Zaanse koeken	10 - 4 oz boxes	9.5	36	0	0	f	22	3	\N	\N
48	Chocolade	10 pkgs.	12.75	15	70	25	f	22	3	\N	\N
49	Maxilaku	24 - 50 g pkgs.	20	10	60	15	f	23	3	\N	\N
50	Valkoinen suklaa	12 - 100 g bars	16.25	65	0	30	f	23	3	\N	\N
51	Manjimup Dried Apples	50 - 300 g pkgs.	53	20	0	10	f	24	7	\N	\N
52	Filo Mix	16 - 2 kg boxes	7	38	0	25	f	24	5	\N	\N
53	Perth Pasties	48 pieces	32.80	0	0	0	t	24	6	\N	\N
54	Tourtière	16 pies	7.45	21	0	10	f	25	6	\N	\N
55	Pâté chinois	24 boxes x 2 pies	24	115	0	20	f	25	6	\N	\N
56	Gnocchi di nonna Alice	24 - 250 g pkgs.	38	21	10	30	f	26	5	\N	\N
57	Ravioli Angelo	24 - 250 g pkgs.	19.5	36	0	20	f	26	5	\N	\N
58	Escargots de Bourgogne	24 pieces	13.25	62	0	20	f	27	8	\N	\N
59	Raclette Courdavault	5 kg pkg.	55	79	0	0	f	28	4	\N	\N
60	Camembert Pierrot	15 - 300 g rounds	34	19	0	0	f	28	4	\N	\N
61	Sirop d'érable	24 - 500 ml bottles	28.5	113	0	25	f	29	2	\N	\N
62	Tarte au sucre	48 pies	49.30	17	0	0	f	29	3	\N	\N
63	Vegie-spread	15 - 625 g jars	43.90	24	0	5	f	7	2	\N	\N
64	Wimmers gute Semmelknödel	20 bags x 4 pieces	33.25	22	80	30	f	12	5	\N	\N
65	Louisiana Fiery Hot Pepper Sauce	32 - 8 oz bottles	21.05	76	0	0	f	2	2	\N	\N
66	Louisiana Hot Spiced Okra	24 - 8 oz jars	17	4	100	20	f	2	2	\N	\N
67	Laughing Lumberjack Lager	24 - 12 oz bottles	14	52	0	10	f	16	1	\N	\N
68	Scottish Longbreads	10 boxes x 8 pieces	12.5	6	10	15	f	8	3	\N	\N
69	Gudbrandsdalsost	10 kg pkg.	36	26	0	15	f	15	4	\N	\N
70	Outback Lager	24 - 355 ml bottles	15	15	10	30	f	7	1	\N	\N
71	Flotemysost	10 - 500 g pkgs.	21.5	26	0	0	f	15	4	\N	\N
72	Mozzarella di Giovanni	24 - 200 g pkgs.	34.80	14	0	0	f	14	4	\N	\N
73	Röd Kaviar	24 - 150 g jars	15	101	0	5	f	17	8	\N	\N
74	Longlife Tofu	5 kg pkg.	10	4	20	5	f	4	7	\N	\N
75	Rhönbräu Klosterbier	24 - 0.5 l bottles	7.75	125	0	25	f	12	1	\N	\N
76	Lakkalikööri	500 ml	18	57	0	20	f	23	1	\N	\N
77	Original Frankfurter grüne Soße	12 boxes	13	32	0	15	f	12	2	\N	\N
\.


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('products_id_seq', 77, true);


--
-- Data for Name: schema_migrations; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY schema_migrations (version) FROM stdin;
20140827231802
20140827232006
20140827232138
20140827232237
20140827232630
20140827233308
20141104015920
20150225184612
20150225192428
20150225192448
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY users (id, email, fb, insta, twitter, password_digest, handle, bio, ie, sn, tf, pj, created_at, updated_at) FROM stdin;
\.


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: admin
--

SELECT pg_catalog.setval('users_id_seq', 1, false);


--
-- Name: airports_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY airports
    ADD CONSTRAINT airports_pkey PRIMARY KEY (id);


--
-- Name: categories_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);


--
-- Name: customers_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: employees_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: flights_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY flights
    ADD CONSTRAINT flights_pkey PRIMARY KEY (id);


--
-- Name: friend_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY friend_requests
    ADD CONSTRAINT friend_requests_pkey PRIMARY KEY (id);


--
-- Name: order_details_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY order_details
    ADD CONSTRAINT order_details_pkey PRIMARY KEY (id);


--
-- Name: orders_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: products_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: users_pkey; Type: CONSTRAINT; Schema: public; Owner: admin; Tablespace: 
--

ALTER TABLE ONLY users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_employees_on_reports_to_id; Type: INDEX; Schema: public; Owner: admin; Tablespace: 
--

CREATE INDEX index_employees_on_reports_to_id ON employees USING btree (reports_to_id);


--
-- Name: index_order_details_on_order_id; Type: INDEX; Schema: public; Owner: admin; Tablespace: 
--

CREATE INDEX index_order_details_on_order_id ON order_details USING btree (order_id);


--
-- Name: index_order_details_on_product_id; Type: INDEX; Schema: public; Owner: admin; Tablespace: 
--

CREATE INDEX index_order_details_on_product_id ON order_details USING btree (product_id);


--
-- Name: index_orders_on_customer_id; Type: INDEX; Schema: public; Owner: admin; Tablespace: 
--

CREATE INDEX index_orders_on_customer_id ON orders USING btree (customer_id);


--
-- Name: index_orders_on_employee_id; Type: INDEX; Schema: public; Owner: admin; Tablespace: 
--

CREATE INDEX index_orders_on_employee_id ON orders USING btree (employee_id);


--
-- Name: index_orders_on_ship_via_id; Type: INDEX; Schema: public; Owner: admin; Tablespace: 
--

CREATE INDEX index_orders_on_ship_via_id ON orders USING btree (ship_via_id);


--
-- Name: index_products_on_category_id; Type: INDEX; Schema: public; Owner: admin; Tablespace: 
--

CREATE INDEX index_products_on_category_id ON products USING btree (category_id);


--
-- Name: index_products_on_supplier_id; Type: INDEX; Schema: public; Owner: admin; Tablespace: 
--

CREATE INDEX index_products_on_supplier_id ON products USING btree (supplier_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: admin; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: public; Type: ACL; Schema: -; Owner: admin
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM admin;
GRANT ALL ON SCHEMA public TO admin;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--

