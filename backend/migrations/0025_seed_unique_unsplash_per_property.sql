START TRANSACTION;

-- Map per-property gallery images to distinct Unsplash photos so each property looks different
UPDATE property_gallery_images g
JOIN properties p ON g.property_id = p.id
SET g.image_url = CASE
  -- PR001
  WHEN p.property_code = 'PR001' AND g.sort_order = 1 THEN 'https://images.unsplash.com/photo-1560185127-6c5f8f4b9b30?auto=format&fit=crop&w=1200&q=80' -- exterior
  WHEN p.property_code = 'PR001' AND g.sort_order = 2 THEN 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80' -- living
  WHEN p.property_code = 'PR001' AND g.sort_order = 3 THEN 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=1200&q=80' -- bedroom
  WHEN p.property_code = 'PR001' AND g.sort_order = 4 THEN 'https://images.unsplash.com/photo-1556911220-e15b29be8c11?auto=format&fit=crop&w=1200&q=80' -- kitchen
  WHEN p.property_code = 'PR001' AND g.sort_order = 5 THEN 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80' -- bathroom
  WHEN p.property_code = 'PR001' AND g.sort_order = 6 THEN 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80' -- garden

  -- PR002
  WHEN p.property_code = 'PR002' AND g.sort_order = 1 THEN 'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR002' AND g.sort_order = 2 THEN 'https://images.unsplash.com/photo-1560448204-e02f11c3d0e2?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR002' AND g.sort_order = 3 THEN 'https://images.unsplash.com/photo-1505691723518-36a5d4a4b3b1?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR002' AND g.sort_order = 4 THEN 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR002' AND g.sort_order = 5 THEN 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR002' AND g.sort_order = 6 THEN 'https://images.unsplash.com/photo-1503417994398-1c8b1eb0d6f1?auto=format&fit=crop&w=1200&q=80'

  -- PR003
  WHEN p.property_code = 'PR003' AND g.sort_order = 1 THEN 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR003' AND g.sort_order = 2 THEN 'https://images.unsplash.com/photo-1598300050578-2f4a7d2a12b6?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR003' AND g.sort_order = 3 THEN 'https://images.unsplash.com/photo-1505691723518-36a5d4a4b3b1?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR003' AND g.sort_order = 4 THEN 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR003' AND g.sort_order = 5 THEN 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR003' AND g.sort_order = 6 THEN 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1200&q=80'

  -- PR004
  WHEN p.property_code = 'PR004' AND g.sort_order = 1 THEN 'https://images.unsplash.com/photo-1505691723518-36a5d4a4b3b1?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR004' AND g.sort_order = 2 THEN 'https://images.unsplash.com/photo-1522708323590-d24dbb6b0267?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR004' AND g.sort_order = 3 THEN 'https://images.unsplash.com/photo-1472224371017-08207f84aaae?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR004' AND g.sort_order = 4 THEN 'https://images.unsplash.com/photo-1541544185300-2dbe0a2aa1b7?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR004' AND g.sort_order = 5 THEN 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR004' AND g.sort_order = 6 THEN 'https://images.unsplash.com/photo-1449844908441-8829872d2607?auto=format&fit=crop&w=1200&q=80'

  -- PR005
  WHEN p.property_code = 'PR005' AND g.sort_order = 1 THEN 'https://images.unsplash.com/photo-1505691723518-36a5d4a4b3b1?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR005' AND g.sort_order = 2 THEN 'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR005' AND g.sort_order = 3 THEN 'https://images.unsplash.com/photo-1499951360447-b19be8fe80f5?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR005' AND g.sort_order = 4 THEN 'https://images.unsplash.com/photo-1548576324-6d5e6ad4a0c9?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR005' AND g.sort_order = 5 THEN 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR005' AND g.sort_order = 6 THEN 'https://images.unsplash.com/photo-1499696010183-02b4f4b6d9a0?auto=format&fit=crop&w=1200&q=80'

  -- PR006
  WHEN p.property_code = 'PR006' AND g.sort_order = 1 THEN 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR006' AND g.sort_order = 2 THEN 'https://images.unsplash.com/photo-1553905095-9b0a7b2f1d3e?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR006' AND g.sort_order = 3 THEN 'https://images.unsplash.com/photo-1505691723518-36a5d4a4b3b1?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR006' AND g.sort_order = 4 THEN 'https://images.unsplash.com/photo-1541544185300-2dbe0a2aa1b7?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR006' AND g.sort_order = 5 THEN 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR006' AND g.sort_order = 6 THEN 'https://images.unsplash.com/photo-1503417994398-1c8b1eb0d6f1?auto=format&fit=crop&w=1200&q=80'

  -- PR007
  WHEN p.property_code = 'PR007' AND g.sort_order = 1 THEN 'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR007' AND g.sort_order = 2 THEN 'https://images.unsplash.com/photo-1600585154340-be6161a56a0c?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR007' AND g.sort_order = 3 THEN 'https://images.unsplash.com/photo-1505691723518-36a5d4a4b3b1?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR007' AND g.sort_order = 4 THEN 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR007' AND g.sort_order = 5 THEN 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR007' AND g.sort_order = 6 THEN 'https://images.unsplash.com/photo-1449844908441-8829872d2607?auto=format&fit=crop&w=1200&q=80'

  -- PR008
  WHEN p.property_code = 'PR008' AND g.sort_order = 1 THEN 'https://images.unsplash.com/photo-1493809842364-78817add7ffb?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR008' AND g.sort_order = 2 THEN 'https://images.unsplash.com/photo-1598300050578-2f4a7d2a12b6?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR008' AND g.sort_order = 3 THEN 'https://images.unsplash.com/photo-1472224371017-08207f84aaae?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR008' AND g.sort_order = 4 THEN 'https://images.unsplash.com/photo-1541544185300-2dbe0a2aa1b7?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR008' AND g.sort_order = 5 THEN 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR008' AND g.sort_order = 6 THEN 'https://images.unsplash.com/photo-1499696010183-02b4f4b6d9a0?auto=format&fit=crop&w=1200&q=80'

  -- PR009
  WHEN p.property_code = 'PR009' AND g.sort_order = 1 THEN 'https://images.unsplash.com/photo-1494526585095-c41746248156?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR009' AND g.sort_order = 2 THEN 'https://images.unsplash.com/photo-1519710164239-da123dc03ef4?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR009' AND g.sort_order = 3 THEN 'https://images.unsplash.com/photo-1505691723518-36a5d4a4b3b1?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR009' AND g.sort_order = 4 THEN 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR009' AND g.sort_order = 5 THEN 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR009' AND g.sort_order = 6 THEN 'https://images.unsplash.com/photo-1449844908441-8829872d2607?auto=format&fit=crop&w=1200&q=80'

  -- PR010
  WHEN p.property_code = 'PR010' AND g.sort_order = 1 THEN 'https://images.unsplash.com/photo-1469474968028-56623f02e42e?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR010' AND g.sort_order = 2 THEN 'https://images.unsplash.com/photo-1598300050578-2f4a7d2a12b6?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR010' AND g.sort_order = 3 THEN 'https://images.unsplash.com/photo-1505691938895-1758d7feb511?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR010' AND g.sort_order = 4 THEN 'https://images.unsplash.com/photo-1540574163026-643ea20ade25?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR010' AND g.sort_order = 5 THEN 'https://images.unsplash.com/photo-1501004318641-b39e6451bec6?auto=format&fit=crop&w=1200&q=80'
  WHEN p.property_code = 'PR010' AND g.sort_order = 6 THEN 'https://images.unsplash.com/photo-1499696010183-02b4f4b6d9a0?auto=format&fit=crop&w=1200&q=80'
  ELSE g.image_url
END
WHERE p.property_code IN ('PR001','PR002','PR003','PR004','PR005','PR006','PR007','PR008','PR009','PR010');

COMMIT;
