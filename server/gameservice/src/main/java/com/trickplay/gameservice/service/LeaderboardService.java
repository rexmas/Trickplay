package com.trickplay.gameservice.service;

import java.util.List;

import org.springframework.security.access.prepost.PostFilter;
import org.springframework.transaction.annotation.Transactional;

import com.trickplay.gameservice.domain.RecordedScore;

@PostFilter("hasRole('ROLE_ADMIN') OR hasRole('ROLE_USER')")
public interface LeaderboardService {

	/*
	 * only top 3 high scores are kept for each user per game
	 * 
	 */
	public static final int MAX_TOP_SCORES_PER_GAME = 3;
	
	public List<RecordedScore> findTopScores(Long gameId, int limit);
	public List<RecordedScore> findBuddyScores(Long gameId);
	public List<RecordedScore> findScoreByUserId(Long gameId);
	
	@Transactional
	public RecordedScore recordScore(Long gameId, long points);	
}
