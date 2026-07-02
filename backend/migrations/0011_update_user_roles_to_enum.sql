UPDATE users
SET role = CASE role
  WHEN 'buyer' THEN 'pembeli'
  WHEN 'marketing' THEN 'staf'
  WHEN 'admin' THEN 'admin'
  ELSE 'pembeli'
END;

ALTER TABLE users
  MODIFY role ENUM('staf', 'admin', 'pembeli') NOT NULL DEFAULT 'pembeli';
