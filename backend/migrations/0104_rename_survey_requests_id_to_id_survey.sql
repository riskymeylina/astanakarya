-- Rename id to id_survey in survey_requests
ALTER TABLE survey_requests CHANGE COLUMN id id_survey BIGINT UNSIGNED NOT NULL AUTO_INCREMENT;
