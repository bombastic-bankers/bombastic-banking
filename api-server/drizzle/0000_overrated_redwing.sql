CREATE TABLE "atms" (
	"atm_id" serial PRIMARY KEY NOT NULL,
	"location" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "email_verification_codes" (
	"id" serial PRIMARY KEY NOT NULL,
	"email" text NOT NULL,
	"token" varchar(255) NOT NULL,
	"expires_at" timestamp NOT NULL
);
--> statement-breakpoint
CREATE TABLE "transaction_ledger" (
	"transaction_id" serial PRIMARY KEY NOT NULL,
	"user_id" integer NOT NULL,
	"amount" numeric(10, 2) NOT NULL,
	"timestamp" timestamp DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "touchless_sessions" (
	"user_id" integer,
	"atm_id" integer,
	"started_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "touchless_sessions_user_id_atm_id_pk" PRIMARY KEY("user_id","atm_id"),
	CONSTRAINT "touchless_sessions_user_id_unique" UNIQUE("user_id"),
	CONSTRAINT "touchless_sessions_atm_id_unique" UNIQUE("atm_id")
);
--> statement-breakpoint
CREATE TABLE "users" (
	"user_id" serial PRIMARY KEY NOT NULL,
	"full_name" text NOT NULL,
	"phone_number" text NOT NULL,
	"email" text NOT NULL,
	"hashed_pin" text NOT NULL,
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
ALTER TABLE "transaction_ledger" ADD CONSTRAINT "transaction_ledger_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "touchless_sessions" ADD CONSTRAINT "touchless_sessions_user_id_users_user_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("user_id") ON DELETE cascade ON UPDATE cascade;--> statement-breakpoint
ALTER TABLE "touchless_sessions" ADD CONSTRAINT "touchless_sessions_atm_id_atms_atm_id_fk" FOREIGN KEY ("atm_id") REFERENCES "public"."atms"("atm_id") ON DELETE cascade ON UPDATE cascade;