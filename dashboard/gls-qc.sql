-- --------------------------------------------------------------------------------
-- QC QUERY against genologics database http://genologics.com/
-- --------------------------------------------------------------------------------

WITH accepting as (
 	SELECT sample.processid as sampleid, process.daterun as daterun
 	FROM processiotracker, process, processtype, artifact, artifact_sample_map, sample
 	WHERE processiotracker.processid=process.processid
 	AND process.typeid=processtype.typeid
 	AND (processtype.displayname='Accept SLX' or processtype.displayname='Aggregate QC (Library Validation)')
 	AND processiotracker.inputartifactid=artifact.artifactid
 	AND artifact_sample_map.artifactid=artifact.artifactid
 	AND artifact_sample_map.processid=sample.processid
),
publishing as (
	SELECT artifact.luid as artifactluid, process.daterun as daterun
	FROM processiotracker, process, processtype, artifact
	WHERE processiotracker.processid=process.processid
	AND process.typeid=processtype.typeid
	AND processtype.displayname='Publishing'
	AND processiotracker.inputartifactid=artifact.artifactid
),
billing as (
	SELECT artifact.luid as artifactluid, process.daterun as daterun
	FROM processiotracker, process,	processtype, artifact
	WHERE processiotracker.processid=process.processid
	AND process.typeid=processtype.typeid
	AND processtype.displayname='Billing'
	AND processiotracker.inputartifactid=artifact.artifactid
	AND process.daterun >= '2016-07-01' AND process.daterun < '2016-08-01'
)

-- SELECT -------------------------------------------------------------------------
SELECT distinct

-- col1: researcher name
--researcher.firstname || ' ' || researcher.lastname as researcher,

-- col2: group
--lab.name as lab,

-- col3: institute name
address.institution as institute,

-- col4: is data for external institute?
ludf1.udfvalue as external,

-- col5: slx id, pool id
case when audf1.udfvalue like 'SLX-%' then audf1.udfvalue else 'SLX-Unknown' end as slxid,

-- col56: flow-cell id
case when pudf3.udfvalue is null then container.name else pudf3.udfvalue end as flowcellid,

-- col7: lane id
'Lane' || containerplacement.wellyposition + 1 as lane,

-- col8: description SLX-ID.FC-ID.s_7
case when audf1.udfvalue like 'SLX-%' then audf1.udfvalue else 'SLX-Unknown' end || '.' ||
case when pudf3.udfvalue is null then container.name
     else pudf3.udfvalue
end || '.s_' ||
containerplacement.wellyposition + 1 as description,

-- col9: platform
itype.name as platform,

-- col10: run type
case when itype.name like 'Hiseq%' then
        case when audf1.udfvalue = 'SLX-11330' and pudf3.udfvalue = 'C9HKWANXX' then 'HiSeq_SE50'
             when audf1.udfvalue = 'SLX-11668' and pudf3.udfvalue = 'C9HKWANXX' then 'HiSeq_SE50'
        	 when pudf3.udfvalue like '______NXX' then 'HiSeq' || '_' || case when pudf2.udfvalue is null then 'SE' else 'PE' end ||
				case when cast(pudf1.udfvalue as int) = 98 and cast(pudf2.udfvalue as int) = 10 then '75'
					 when cast(pudf1.udfvalue as int) = 114 and cast(pudf2.udfvalue as int) = 98 then '125'
					 else pudf1.udfvalue
				end
             when pudf3.udfvalue like '______CXX' then 'HiSeq2000' || '_' || case when pudf2.udfvalue is null then 'SE' else 'PE' end || pudf1.udfvalue
             when pudf3.udfvalue like '______DXX' then 'HiSeqRapid' || '_' || case when pudf2.udfvalue is null then 'SE' else 'PE' end || pudf1.udfvalue
             when pudf3.udfvalue like '______BXX' then 'HiSeq4000' || '_' ||
             	case when pudf2.udfvalue is null then 'SE' || pudf1.udfvalue else 'PE' ||
					case when cast(pudf1.udfvalue as int) <= 75 then '75'
						 when cast(pudf1.udfvalue as int) > 75 and cast(pudf1.udfvalue as int) <= 150 then '150'
						 else pudf1.udfvalue
					end
             	end
             else 'HiSeqUnknown' || '_' || case when pudf2.udfvalue is null then 'SE' else 'PE' end || pudf1.udfvalue
        end
     when itype.name = 'Miseq' then 'MiSeq' || '_' ||
        case when cast(pudf1.udfvalue as int)+cast(coalesce(pudf2.udfvalue,'0') as int) <= 150 then 'UpTo150'
        	 else 'UpTo600'
     	end
     when itype.name = 'Nextseq' then 'NextSeq' || '_' ||
     	case when pudf4.udfvalue = 'NextSeq Mid' then 'Mid' || '_' ||
			case when cast(pudf1.udfvalue as int)+cast(coalesce(pudf2.udfvalue,'0') as int) <= 150 then 'UpTo150'
				 else 'UpTo300'
        	end
     	else 'High' || '_' ||
			case when cast(pudf1.udfvalue as int)+cast(coalesce(pudf2.udfvalue,'0') as int) <= 75 then 'UpTo75'
				 when cast(pudf1.udfvalue as int)+cast(coalesce(pudf2.udfvalue,'0') as int) > 75 and cast(pudf1.udfvalue as int)+cast(coalesce(pudf2.udfvalue,'0') as int) <= 150 then 'UpTo150'
				 else 'UpTo300'
        	end
     	end
     else itype.name || '_' || case when pudf2.udfvalue is null then 'SE' else 'PE' end || pudf1.udfvalue
end as runtype,

-- col11: cycles
cast(pudf1.udfvalue as int)+cast(coalesce(pudf2.udfvalue,'0') as int) as cycles,

-- col12: billable
audf2.udfvalue as billable,

-- col13: yield
audf3.udfvalue as yield,

-- col14: Q30
audf4.udfvalue as q30,

-- col15: acceptance date
to_char(accepting.daterun, 'YYYY-MM-DD') as acceptancedate,

-- col16: sequencing date
to_char(to_date(pudf5.udfvalue, 'YYYY-MM-DD'), 'YYYY-MM-DD') as sequencingdate,

-- col17: publishing date
to_char(publishing.daterun, 'YYYY-MM-DD') as publishingdate,

-- col18: billing date
to_char(billing.daterun, 'YYYY-MM-DD') as billindate,

-- col19: turnaround time
publishing.daterun - accepting.daterun as turnaroundtime

-- FROM ---------------------------------------------------------------------------
FROM accepting,
publishing,
billing,
process
LEFT OUTER JOIN process_udf_view as pudf1 on (pudf1.processid=process.processid AND pudf1.udfname like 'Read 1 Cycle%')
LEFT OUTER JOIN process_udf_view as pudf2 on (pudf2.processid=process.processid AND pudf2.udfname like 'Read 2 Cycle%')
LEFT OUTER JOIN process_udf_view as pudf3 on (pudf3.processid=process.processid AND pudf3.udfname = 'Flow Cell ID')
LEFT OUTER JOIN process_udf_view as pudf4 on (pudf4.processid=process.processid AND pudf4.udfname = 'Chemistry')
LEFT OUTER JOIN process_udf_view as pudf5 on (pudf5.processid=process.processid AND pudf5.udfname = 'Finish Date'),
processtype,
installation,
instrument,
itype,
processiotracker,
artifact
LEFT OUTER JOIN artifact_udf_view as audf1 on (audf1.artifactid=artifact.artifactid AND audf1.udfname = 'SLX Identifier')
LEFT OUTER JOIN artifact_udf_view as audf2 on (audf2.artifactid=artifact.artifactid AND audf2.udfname = 'Billable')
LEFT OUTER JOIN artifact_udf_view as audf3 on (audf3.artifactid=artifact.artifactid AND audf3.udfname = 'Yield (Mreads)')
LEFT OUTER JOIN artifact_udf_view as audf4 on (audf4.artifactid=artifact.artifactid AND audf4.udfname = '% Bases >=Q30 R1'),
containerplacement,
container,
artifact_sample_map,
sample,
project,
researcher,
lab
LEFT OUTER JOIN address on (lab.billingaddressid=address.addressid)
LEFT OUTER JOIN entity_udf_view as ludf1 on (ludf1.attachtoid=lab.labid and ludf1.udfname='External')

-- WHERE --------------------------------------------------------------------------
WHERE process.typeid = processtype.typeid
AND processtype.displayname like '%Run%'
AND process.installationid=installation.id
AND installation.instrumentid=instrument.instrumentid
AND instrument.typeid=itype.typeid
AND process.processid=processiotracker.processid
AND processiotracker.inputartifactid=artifact.artifactid
AND containerplacement.processartifactid=artifact.artifactid
AND containerplacement.containerid=container.containerid
AND artifact_sample_map.artifactid=artifact.artifactid
AND artifact_sample_map.processid=sample.processid
AND sample.projectid=project.projectid
AND project.researcherid=researcher.researcherid
AND researcher.labid=lab.labid
AND sample.processid=accepting.sampleid
AND artifact.luid=publishing.artifactluid
AND artifact.luid=billing.artifactluid
AND sample.name NOT LIKE 'Genomics Control%'
AND project.name != 'Controls'
AND sample.controltypeid is null
-- ORDER BY -----------------------------------------------------------------------
ORDER BY billable, flowcellid, lane
