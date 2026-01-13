CREATE TABLE "sms_verification_codes" (
	"id" serial PRIMARY KEY NOT NULL,
	"phone_number" text NOT NULL,
	"verified_at" timestamp,
	"created_at" timestamp DEFAULT now(),
	CONSTRAINT "sms_verification_codes_phone_number_unique" UNIQUE("phone_number")
);
--> statement-breakpoint
ALTER TABLE "email_verification_codes" ADD COLUMN "verified_at" timestamp;--> statement-breakpoint
ALTER TABLE "email_verification_codes" ADD COLUMN "created_at" timestamp DEFAULT now() NOT NULL;