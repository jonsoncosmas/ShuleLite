-- Store exam names separately so assessments can be grouped and searched by exam.
ALTER TABLE pupil_results ADD COLUMN exam_name VARCHAR(120) NULL AFTER subject;
UPDATE pupil_results SET exam_name=assessment WHERE exam_name IS NULL OR exam_name='';
ALTER TABLE pupil_results MODIFY exam_name VARCHAR(120) NOT NULL;
