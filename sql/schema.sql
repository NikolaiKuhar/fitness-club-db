-- Fitness Club DB - PostgreSQL schema (final)
DROP SCHEMA IF EXISTS fit CASCADE;
CREATE SCHEMA fit;
SET search_path = fit;

-- 1) Core
CREATE TABLE member (
  member_id   BIGSERIAL PRIMARY KEY,
  full_name   VARCHAR(200) NOT NULL,
  email       VARCHAR(200) UNIQUE,
  phone       VARCHAR(30),
  birth_date  DATE,
  status      VARCHAR(20) NOT NULL DEFAULT 'active'
              CHECK (status IN ('active','frozen','blocked')),
  created_at  TIMESTAMP NOT NULL DEFAULT now()
);

CREATE TABLE trainer (
  trainer_id  BIGSERIAL PRIMARY KEY,
  full_name   VARCHAR(200) NOT NULL,
  hire_date   DATE,
  phone       VARCHAR(30),
  email       VARCHAR(200) UNIQUE
);

CREATE TABLE trainer_qualification (
  qualification_id BIGSERIAL PRIMARY KEY,
  trainer_id       BIGINT NOT NULL REFERENCES trainer(trainer_id) ON DELETE CASCADE,
  title            VARCHAR(150) NOT NULL,
  issued_by        VARCHAR(150),
  issued_at        DATE,
  level            VARCHAR(30),
  CONSTRAINT uq_trainer_qual UNIQUE (trainer_id, title, issued_at)
);

CREATE TABLE membership_plan (
  plan_id          BIGSERIAL PRIMARY KEY,
  name             VARCHAR(100) NOT NULL UNIQUE,
  duration_months  INT NOT NULL CHECK (duration_months > 0),
  price            NUMERIC(10,2) NOT NULL CHECK (price >= 0),
  visits_per_week  INT NOT NULL CHECK (visits_per_week >= 0)
);

-- 2) Membership details
CREATE TABLE subscription (
  subscription_id BIGSERIAL PRIMARY KEY,
  member_id       BIGINT NOT NULL REFERENCES member(member_id) ON DELETE RESTRICT,
  plan_id         BIGINT NOT NULL REFERENCES membership_plan(plan_id) ON DELETE RESTRICT,
  start_date      DATE NOT NULL,
  end_date        DATE NOT NULL,
  status          VARCHAR(20) NOT NULL DEFAULT 'active'
                  CHECK (status IN ('active','expired','frozen')),
  CHECK (end_date >= start_date)
);

-- 3) Programs & enrollments
CREATE TABLE program (
  program_id  BIGSERIAL PRIMARY KEY,
  name        VARCHAR(120) NOT NULL UNIQUE,
  type        VARCHAR(20)  NOT NULL CHECK (type IN ('group','individual')),
  difficulty  VARCHAR(20)  NOT NULL CHECK (difficulty IN ('beginner','intermediate','advanced')),
  description TEXT
);

CREATE TABLE program_enrollment (
  member_id    BIGINT NOT NULL REFERENCES member(member_id) ON DELETE CASCADE,
  program_id   BIGINT NOT NULL REFERENCES program(program_id) ON DELETE CASCADE,
  enrolled_at  TIMESTAMP NOT NULL DEFAULT now(),
  status       VARCHAR(20) NOT NULL DEFAULT 'active'
               CHECK (status IN ('active','cancelled','completed')),
  PRIMARY KEY (member_id, program_id)
);

-- 4) Sessions
CREATE TABLE session (
  session_id  BIGSERIAL PRIMARY KEY,
  program_id  BIGINT NOT NULL REFERENCES program(program_id) ON DELETE RESTRICT,
  trainer_id  BIGINT NOT NULL REFERENCES trainer(trainer_id) ON DELETE RESTRICT,
  starts_at   TIMESTAMP NOT NULL,
  ends_at     TIMESTAMP NOT NULL,
  capacity    INT NOT NULL CHECK (capacity > 0),
  room        VARCHAR(80),
  CHECK (ends_at > starts_at)
);

CREATE UNIQUE INDEX uq_session_room_start ON session(room, starts_at);

CREATE TABLE session_attendance (
  session_id   BIGINT NOT NULL REFERENCES session(session_id) ON DELETE CASCADE,
  member_id    BIGINT NOT NULL REFERENCES member(member_id) ON DELETE CASCADE,
  attended_at  TIMESTAMP NOT NULL,
  status       VARCHAR(20) NOT NULL DEFAULT 'present'
               CHECK (status IN ('present','absent','late','cancelled')),
  PRIMARY KEY (session_id, member_id)
);

-- 5) Payments
CREATE TABLE payment (
  payment_id      BIGSERIAL PRIMARY KEY,
  member_id       BIGINT NOT NULL REFERENCES member(member_id) ON DELETE RESTRICT,
  subscription_id BIGINT REFERENCES subscription(subscription_id) ON DELETE SET NULL,
  amount          NUMERIC(10,2) NOT NULL CHECK (amount > 0),
  paid_at         TIMESTAMP NOT NULL DEFAULT now(),
  method          VARCHAR(20) NOT NULL CHECK (method IN ('card','cash','online')),
  note            TEXT
);

-- 6) Hierarchy
CREATE TABLE employee (
  employee_id BIGSERIAL PRIMARY KEY,
  full_name   VARCHAR(200) NOT NULL,
  role        VARCHAR(50),
  manager_id  BIGINT REFERENCES employee(employee_id) ON DELETE SET NULL
);

-- 7) Helpful indexes (FK indexes)
CREATE INDEX ix_subscription_member   ON subscription(member_id);
CREATE INDEX ix_subscription_plan     ON subscription(plan_id);
CREATE INDEX ix_program_enroll_member ON program_enrollment(member_id);
CREATE INDEX ix_program_enroll_prog   ON program_enrollment(program_id);
CREATE INDEX ix_session_program       ON session(program_id);
CREATE INDEX ix_session_trainer       ON session(trainer_id);
CREATE INDEX ix_attendance_session    ON session_attendance(session_id);
CREATE INDEX ix_attendance_member     ON session_attendance(member_id);
CREATE INDEX ix_payment_member        ON payment(member_id);
CREATE INDEX ix_payment_subscription  ON payment(subscription_id);
