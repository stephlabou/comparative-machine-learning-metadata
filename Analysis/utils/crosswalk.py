from collections import namedtuple


RepositoryExtract = namedtuple(
    'RepositoryExtract',
    ['repository', 'object_type']
)
RepositoryCrosswalk = namedtuple(
    'RepositoryCrosswalk',
    ['unique_identifier', 'license', 'description', 'methods', 'publication_date',
     'file_size', 'url', 'dataset_size', 'domain', 'technical_details', 'keyword',
     'geographic_keyword', 'scientific_keyword', 'funding_agency', 'views', 'downloads',
     'citation_count', 'resource_type', 'file_extension', 'file_format', 'media_type',
     'related_resource_type', 'related_resource_identifier', 'original_data_url',
     'primary_manuscript', 'related_resource_relation_type', 'citation']
)

property_crosswalk = {
    'dryad': {
        'records': RepositoryCrosswalk(
            'id', 'license', 'abstract', 'methods', 'publicationDate', 'size', 'path', 'storageSize', 'fieldOfScience',
            'usageNotes', 'keywords', {'locations': 'place'}, None, {'funders': 'organization'}, 'numViews',
            'numDownloads', 'numCitations', None, 'path', None, 'mimeType', {'relatedWorks': 'relationship'}, 
            {'relatedWorks': 'identifier'}, None, {'relatedWorks': 'identifier'}, {'relatedWorks': 'identifierType'}, None
        )
    },
    'figshare': {
        'articles': RepositoryCrosswalk(
            'id', {'license': 'name'}, 'description', None, {'timeline_metadata': 'firstOnline'},
            {'files': 'size'}, {'files': 'download_url'}, {'files': 'size'}, {'categories': 'title'}, None, 'tags',
            'tags', 'tags', {'funding_list': 'title'}, None, None, None, 'defined_type_name_metadata',
            {'files': 'name'}, None, None, None, 'resource_doi_metadata', None, 'resource_doi_metadata',
            None, 'citation'
        )
    },
    'dataverse': {
        'datasets': RepositoryCrosswalk(
            'global_id', 'terms_of_use', 'description', None, 'published_at', {'files': 'contentSize'}, {'files': 'contentUrl'},
            {'files': 'contentSize'}, 'subjects', None, 'keywords', 'geographicCoverage',
            None, 'grant_info', None, 'num_downloads', None, 'kind_of_data', {'files': 'name'}, {'files': 'fileFormat'}, None,
            None, 'relatedMaterial', None, {'publications': 'url'}, None, 'citationHtml'
        ),
        'files': RepositoryCrosswalk(
            None, None, None, None, 'published_at', 'size_in_bytes', 'url', None, None, None, None, None, None, None,
            None, None, None, None, 'name', 'file_type', 'file_content_type', None, None, None, None, None, None
        )
    },
    'zenodo': {
        'records': RepositoryCrosswalk(
            'id', {'metadata': {'license': 'id'}}, {'metadata': 'description'}, None, {'metadata': 'publication_date'},
            {'files': 'size'}, {'files': {'links': 'self'}}, {'files': 'size'}, None, None,
            {'metadata': 'keywords'}, {'metadata': 'keywords'},
            ('genus', 'kingdom', 'order', 'phylum', 'scientificNameAuthorship', 'specificEpithet'),
            {'metadata': {'grants': {'funder': 'name'}}}, {'stats': ('views', 'unique_views')},
            {'stats': ('downloads', 'unique_downloads')}, None, {'metadata': {'resource_type': 'title'}},
            {'files': 'type'}, None, None, {'metadata': {'related_identifiers': 'relation'}},
            {'metadata': {'related_identifiers': 'identifier'}}, None, {'metadata': {'related_identifiers': 'identifier'}},
            {'metadata': {'related_identifiers': 'relation'}}, None
        )
    },
    'kaggle': {
        'datasets': RepositoryCrosswalk(
            'id', {'licenses': 'name'}, 'description_metadata', None, 'lastUpdated', None, None, 'totalBytes', None,
            None, ('keywords', {'tags': 'name'}), None, None, None, 'totalViews', 'downloadCount', None, None,
            None, None, None, None, None, None, None, None, None
        )
    },
    'openml': {
        'datasets': RepositoryCrosswalk(
            'did', 'licence', 'description', None, 'upload_date', None, 'url', None, None, 'qualities', 'tag', None,
            None, None, None, ('num_downloads', 'num_unique_downloads'), None, None, None, 'format', None,
            None, 'paper_url', 'original_data_url', None, None, None
        )
    },
    'uci': {
        'datasets': RepositoryCrosswalk(
            'url', 'license', 'abstract', None, 'donation_date', None, 'files', None, 'subject_area', 'dataset_characteristics',
            'keywords', None, None, None, 'num_views', None, 'num_citations', None, 'files', None, None, None,
            None, None, 'papers', None, 'citation_requests/acknowledgements'
        )
    },
    'ucsd': {
        'records': RepositoryCrosswalk(
            'Object_Unique_ID', 'license_licenseURI', 'Note_description', 'Note_methods', 'Date_issued',
            'file_File_size', 'file_Name', 'file_File_size', None, 'Note_technical_details',
            'Subject_topic', 'Subject_geographic', 'Subject_scientific_name', 'Note_funding',
            None, None, None, 'Type_of_Resource', 'file_Name', 'file_File_format',
            'file_Media_type', None, 'Note_related_publications',
            'Related resource', ({'Note': 'related publications'}, 'Related resource'),
            {'relatedResource': 'type'}, 'Note_preferred citation'
        )
    }
}