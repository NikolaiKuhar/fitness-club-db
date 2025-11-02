SET search_path = fit;

-- Members
INSERT INTO member (full_name, email, status) VALUES
('Anna Petrova','anna@example.com','active'),
('Mikalai Kukhar','mikalai@example.com','active'),
('Lina Karpovich','lina@example.com','active');

-- Trainers
INSERT INTO trainer (full_name, email, hire_date) VALUES
('John Coach','john@club.com','2023-06-01'),
('Kate Strong','kate@club.com','2024-01-15');

-- Qualifications
INSERT INTO trainer_qualification (trainer_id, title, issued_by, issued_at, level) VALUES
(1,'ACE Certified','ACE','2023-06-01','L2'),
(2,'CrossFit L1','CrossFit','2024-02-10','L1');

-- Plans
INSERT INTO membership_plan (name, duration_months, price, visits_per_week) VALUES
('Monthly Standard', 1, 49.90, 3),
('Unlimited Pro', 1, 79.90, 0);

-- Subscriptions
INSERT INTO subscription (member_id, plan_id, start_date, end_date, status) VALUES
(1, 1, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 month', 'active'),
(2, 2, CURRENT_DATE, CURRENT_DATE + INTERVAL '1 month', 'active');

-- Programs
INSERT INTO program (name, type, difficulty, description) VALUES
('Functional Training','group','beginner','Group class for beginners'),
('Personal Strength','individual','intermediate','1-on-1 program');

-- Enrollments
INSERT INTO program_enrollment (member_id, program_id) VALUES
(1,1),
(2,1),
(2,2);

-- Sessions
INSERT INTO session (program_id, trainer_id, starts_at, ends_at, capacity, room) VALUES
(1, 1, now() + INTERVAL '1 day',      now() + INTERVAL '1 day 1 hour', 20, 'Room A'),
(1, 2, now() + INTERVAL '2 days',     now() + INTERVAL '2 days 1 hour', 18, 'Room B'),
(2, 2, now() + INTERVAL '3 days 10h', now() + INTERVAL '3 days 11h',    1,  'PT-1');

-- Attendance
INSERT INTO session_attendance (session_id, member_id, attended_at, status) VALUES
(1,1, now() + INTERVAL '1 day', 'present'),
(1,2, now() + INTERVAL '1 day', 'present'),
(2,2, now() + INTERVAL '2 days','absent');

-- Payments
INSERT INTO payment (member_id, subscription_id, amount, method, note) VALUES
(1, 1, 49.90, 'card', 'Monthly Standard'),
(2, 2, 79.90, 'online', 'Unlimited Pro');

-- Demo queries
-- 1) Active subscriptions
SELECT m.full_name, p.name AS plan_name, s.start_date, s.end_date
FROM member m
JOIN subscription s ON s.member_id = m.member_id
JOIN membership_plan p ON p.plan_id = s.plan_id
WHERE s.status = 'active';

-- 2) Trainer load
SELECT t.full_name AS trainer, COUNT(s.session_id) AS sessions_count
FROM trainer t
LEFT JOIN session s ON s.trainer_id = t.trainer_id
GROUP BY t.trainer_id, t.full_name
ORDER BY sessions_count DESC;

-- 3) Attendance per session
SELECT s.session_id, pr.name AS program, COUNT(sa.member_id) AS attendees
FROM session s
JOIN program pr ON pr.program_id = s.program_id
LEFT JOIN session_attendance sa ON sa.session_id = s.session_id
GROUP BY s.session_id, pr.name
ORDER BY s.session_id;
